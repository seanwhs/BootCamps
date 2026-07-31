# Part 1: Governance, Leadership & Cyber Risk Strategy

## Learning Objectives

By completing this tutorial, you will:

- Position cybersecurity as an enterprise business risk rather than an IT technical issue
- Build executive sponsorship and establish Board oversight structures
- Create a comprehensive enterprise cybersecurity governance framework
- Define clear organizational roles, responsibilities, and accountability using RACI matrices
- Develop a cyber risk management framework aligned with business objectives
- Align cybersecurity initiatives with corporate strategy and international frameworks
- Establish security policies, standards, and a governance lifecycle
- Create a cybersecurity strategy and 3-year roadmap

## Key Concepts & Frameworks

### Why Governance Matters First

Imagine building a house. You wouldn't start with the roof or the plumbing. You'd begin with a blueprint, a foundation, and a structural framework. Cybersecurity is no different. Without proper governance—the decision-making structures, accountability, and strategic direction—your security controls will be disconnected, ineffective, and expensive.

Governance answers three critical questions:

1. **Who decides?** (Decision-making authority)
2. **What do we protect?** (Risk appetite and priorities)
3. **How do we know we're successful?** (Measurement and accountability)

### Core Frameworks We'll Use

**NIST Cybersecurity Framework (CSF) 2.0**
The CSF provides a common language for cybersecurity risk management. Its six core functions form the backbone of our entire series:

```
┌─────────────┐
│   GOVERN    │ ← We are here (Part 1)
├─────────────┤
│  IDENTIFY   │ ← Part 2
├─────────────┤
│   PROTECT   │ ← Part 3
├─────────────┤
│   DETECT    │ ← Part 4
├─────────────┤
│   RESPOND   │ ← Part 4
├─────────────┤
│   RECOVER   │ ← Part 4
└─────────────┘
```

**ISO/IEC 27001:2022**
The international standard for Information Security Management Systems (ISMS). We'll use its Annex A controls as our control baseline.

**CIS Critical Security Controls**
A prioritized set of actions for cyber defense. We'll reference these in our control implementation.

## Hands-On Implementation

### Step 1: Establish the Governance Structure

**The Target:** Create the foundational governance documents that define how cybersecurity decisions are made.

**The Concept:** Think of governance like a corporate org chart for security. It defines who has what authority, who reports to whom, and how decisions flow through the organization. In a multinational, this becomes complex—you need global consistency with regional flexibility.

#### 1.1 Create the Executive Governance Charter

Let's create the document that establishes the cybersecurity governance structure.

**File:** `01-governance/charter/cybersecurity-governance-charter.md`

```markdown
---
title: Enterprise Cybersecurity Governance Charter
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Annual
---

# Cybersecurity Governance Charter

## 1. Purpose

This Charter establishes the cybersecurity governance structure for [Organization Name], defining the authority, composition, responsibilities, and operating procedures for cybersecurity oversight and decision-making across all global operations.

## 2. Scope

This Charter applies to:
- All subsidiaries, joint ventures, and business units globally
- All employees, contractors, and third parties accessing organizational resources
- All information assets, regardless of location or classification
- All technology and operational processes

## 3. Guiding Principles

### 3.1 Cybersecurity is a Business Risk
Cybersecurity is managed as an enterprise business risk, not an IT technical issue. Decisions consider business impact, not just technical severity.

### 3.2 Risk-Based Approach
Security investments and controls are prioritized based on risk to the business, aligned with risk appetite.

### 3.3 Shared Responsibility
Every employee and partner shares responsibility for cybersecurity. Accountability is clearly defined and enforced.

### 3.4 Continuous Improvement
The security program evolves continuously through measurement, learning, and adaptation.

### 3.5 Regulatory Compliance
Operations comply with all applicable laws, regulations, and contractual obligations in every jurisdiction.

## 4. Governance Structure

### 4.1 Board of Directors Cybersecurity Committee

**Composition:** 3-5 independent Board members, including the Audit Committee Chair

**Meeting Frequency:** Quarterly minimum, with ad-hoc sessions for significant incidents

**Responsibilities:**
- Approve cybersecurity strategy and annual budget
- Oversee enterprise risk posture and risk appetite
- Review key risk indicators and significant security events
- Approve major security investments and initiatives
- Oversee regulatory compliance and audit findings
- Ensure executive accountability for cybersecurity

**Reporting:** Reports to the full Board of Directors

### 4.2 Executive Cybersecurity Council

**Composition:**
- Chief Information Security Officer (CISO) - Chair
- Chief Information Officer (CIO)
- Chief Risk Officer (CRO)
- Chief Legal Officer (CLO)
- Chief Privacy Officer (CPO)
- Chief Human Resources Officer (CHRO)
- Head of Internal Audit
- Business Unit Presidents (rotating members)

**Meeting Frequency:** Monthly minimum

**Responsibilities:**
- Set strategic cybersecurity direction
- Allocate resources and approve investments
- Make key risk decisions within Board-approved risk appetite
- Oversee security program execution
- Ensure business unit alignment
- Review and approve key security policies

### 4.3 Cybersecurity Operational Committee

**Composition:**
- Deputy CISO - Chair
- Regional Security Directors (APAC, EMEA, Americas)
- Security Architecture Lead
- Incident Response Lead
- Compliance and Privacy Lead
- Business Unit Security Liaisons
- IT Operations Leads

**Meeting Frequency:** Bi-weekly

**Responsibilities:**
- Operationalize strategic decisions
- Manage security projects and initiatives
- Coordinate across regions and functions
- Monitor security operations and metrics
- Report to Executive Council

### 4.4 Regional Security Committees

**Composition:**
- Regional Security Lead - Chair
- Regional IT Lead
- Regional Legal Counsel
- Regional Compliance Lead
- Business Unit Representatives

**Meeting Frequency:** Monthly

**Responsibilities:**
- Address regional regulatory requirements
- Adapt global policies to local context
- Manage regional risk
- Coordinate with local authorities
- Escalate to global governance as needed
```

#### 1.2 Create the RACI Matrix

**The Target:** Create a comprehensive RACI (Responsible, Accountable, Consulted, Informed) matrix defining roles and responsibilities.

**The Concept:** In any large organization, confusion about "who does what" is the enemy of effective security. RACI defines:

- **Responsible**: Who does the work
- **Accountable**: Who ensures it gets done (the "buck stops here" person)
- **Consulted**: Who provides input
- **Informed**: Who needs to know the outcome

Think of it like a restaurant: The chef is **Responsible** for cooking your meal. The head chef is **Accountable** for its quality. The sous chef is **Consulted** on special preparation. The waiter is **Informed** when it's ready to serve.

**File:** `01-governance/raci/cybersecurity-raci-matrix.md`

```markdown
---
title: Cybersecurity RACI Matrix
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Bi-annual
---

# Cybersecurity RACI Matrix

## Role Definitions

| Role | Abbreviation | Description |
|------|--------------|-------------|
| Board Cybersecurity Committee | BCC | Board-level oversight |
| Chief Information Security Officer | CISO | Executive security leader |
| Chief Information Officer | CIO | IT executive |
| Chief Risk Officer | CRO | Enterprise risk executive |
| Chief Legal Officer | CLO | Legal and regulatory executive |
| Chief Privacy Officer | CPO | Privacy and data protection |
| Business Unit Head | BUH | Business unit executive |
| Regional Security Director | RSD | Regional security lead |
| Security Architect | SA | Enterprise security design |
| Security Operations Lead | SOC | Security operations management |
| Incident Response Lead | IR | Incident management |
| Compliance Manager | CM | Regulatory compliance |
| IT Operations Lead | ITOPS | IT infrastructure operations |
| Application Owner | AO | Application responsibility |
| Data Owner | DO | Data classification and protection |
| Procurement Manager | PM | Vendor management |
| HR Manager | HR | People processes |
| All Employees | EMP | Individual responsibility |

## RACI Matrix

### Strategy and Governance

| Activity | BCC | CISO | CIO | CRO | CLO | CPO | BUH | RSD | CM | HR |
|----------|-----|------|-----|-----|-----|-----|-----|-----|-----|-----|
| Approve enterprise security strategy | A | R | C | C | C | C | C | C | C | C |
| Develop security strategy and roadmap | - | R | C | A | - | - | C | C | - | - |
| Define risk appetite | A | R | C | C | C | - | C | - | C | - |
| Approve security policies | A | R | C | C | C | C | C | C | C | C |
| Conduct enterprise risk assessment | - | R | C | A | C | - | C | C | C | - |
| Report to Board on security posture | R | C | - | C | - | - | - | - | - | - |

### Risk Management

| Activity | CISO | CRO | BUH | RSD | SA | CM | AO | DO | PM |
|----------|------|-----|-----|-----|-----|-----|-----|-----|-----|
| Identify and classify business risks | R | C | C | C | - | C | A | C | - |
| Document risk register | R | C | - | C | - | - | - | A | - |
| Assess risk remediation options | R | C | - | R | R | - | - | - | - |
| Approve risk acceptance | A | C | R | - | - | - | - | A | - |
| Track risk mitigation progress | R | C | - | R | - | - | - | - | - |
| Third-party risk assessment | R | - | - | C | - | - | C | - | A |
| Vendor security due diligence | R | - | C | - | - | - | - | - | A |

### Asset Management

| Activity | CISO | IT OPS | AO | DO | SA | RSD | CM |
|----------|------|--------|----|----|----|-----|-----|
| Maintain asset inventory | R | C | - | - | - | C | - |
| Classify data assets | R | - | C | A | - | C | C |
| Approve data classification | A | - | - | R | - | - | C |
| Implement asset protections | R | C | - | - | R | - | - |
| Review asset inventory regularly | R | C | - | - | - | R | C |

### Identity and Access

| Activity | CISO | IT OPS | SA | AO | DO | HR | EMP |
|----------|------|--------|-----|----|----|-----|------|
| Define identity governance policies | A | R | C | - | C | R | - |
| Provision user access | C | R | - | C | C | R | - |
| Approve privileged access | A | R | - | - | - | - | - |
| Review access rights periodically | R | R | - | C | A | - | - |
| Maintain least privilege access | R | R | - | C | A | - | - |

### Security Operations

| Activity | CISO | SOC | IR | SA | RSD | IT OPS | CM |
|----------|------|-----|-----|-----|-----|--------|-----|
| Operate security monitoring | R | A | - | - | - | - | - |
| Manage security incidents | R | R | A | - | R | C | C |
| Conduct incident response | R | C | A | - | R | C | - |
| Perform digital forensics | R | R | A | - | - | - | - |
| Review incident learnings | A | R | R | - | C | C | C |
| Test incident response plans | R | R | A | C | R | R | - |

### Business Continuity

| Activity | CISO | CRO | BUH | IT OPS | IR | CM |
|----------|------|-----|-----|--------|----|-----|
| Develop business continuity plans | R | C | A | R | - | - |
| Test business continuity plans | R | C | A | R | R | - |
| Maintain disaster recovery capabilities | R | - | C | A | - | - |
| Ensure immutable backup strategy | R | - | - | A | - | - |
| Test recovery procedures | R | - | C | A | R | - |

### Compliance and Audit

| Activity | CISO | CLO | CPO | CM | IT OPS | AO | HR |
|----------|------|-----|-----|----|--------|----|-----|
| Interpret regulatory requirements | C | A | R | C | - | - | - |
| Map controls to requirements | R | C | C | A | - | - | - |
| Evidence collection for audits | R | C | C | A | C | C | C |
| Remediate audit findings | R | - | - | C | A | C | - |
| Report compliance status | R | C | C | A | - | - | - |

### Security Awareness

| Activity | CISO | CM | HR | BUH | RSD | EMP |
|----------|------|----|-----|----|-----|------|
| Develop security awareness program | A | R | C | - | R | - |
| Deliver security training | R | R | R | - | - | R |
| Conduct phishing simulations | R | A | R | - | R | - |
| Report suspicious activity | - | - | - | A | - | R |
| Complete required training | - | - | R | A | - | R |

## Escalation Paths

### Incident Escalation

```
Level 1: SOC Analyst (Initial Triage)
  ↓ (within 30 min)
Level 2: Incident Response Lead (Investigation)
  ↓ (within 2 hours)
Level 3: CISO (Major Incident Declaration)
  ↓ (within 1 hour)
Level 4: Executive Cybersecurity Council
  ↓ (within 4 hours)
Level 5: Board Cybersecurity Committee
```

### Risk Escalation

```
Business Unit Risk Owner
  ↓ (risks exceeding appetite)
Regional Security Director
  ↓ (risks impacting multiple regions)
CISO
  ↓ (enterprise-level risks)
Executive Cybersecurity Council
  ↓ (risks requiring budget or strategic decisions)
Board Cybersecurity Committee
```

## Review Process

This RACI matrix will be reviewed:
- Bi-annually for accuracy and completeness
- Following major organizational changes
- Following significant security incidents
- On request by any executive stakeholder
```

### Step 2: Define the Risk Management Framework

**The Target:** Create a comprehensive risk management framework that aligns with NIST CSF 2.0 and ISO/IEC 27001.

**The Concept:** Risk management is how we decide what to protect and how much to spend. Think of it like a car: you don't need a bulletproof tank for normal driving, but you do need seatbelts and airbags. The amount and type of protection depends on your risk appetite—how much risk you're willing to accept.

#### 2.1 Create the Risk Management Policy

**File:** `01-governance/policies/risk-management-policy.md`

```markdown
---
title: Enterprise Risk Management Policy
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Annual
---

# Enterprise Risk Management Policy

## 1. Purpose

This policy establishes a consistent, enterprise-wide approach to identifying, assessing, managing, and monitoring cybersecurity risks across all global operations.

## 2. Scope

All business units, subsidiaries, and functions globally.

## 3. Risk Management Principles

### 3.1 Risk-Based Decision Making
All security decisions are informed by risk assessments and aligned with the organization's risk appetite.

### 3.2 Comprehensive Risk View
We consider threats from all sources: external, internal, third-party, and systemic.

### 3.3 Continuous Assessment
Risk is assessed continuously, not as a one-time event.

### 3.4 Transparency
Risk information is communicated openly to enable informed decisions.

### 3.5 Accountability
Risk owners are clearly identified and held accountable.

## 4. Risk Appetite and Tolerance

### 4.1 Risk Appetite Statement
[Organization Name] maintains a **moderate** cybersecurity risk appetite. We accept:

- Controlled risks in support of business innovation and growth
- Calculated risks when mitigation would stifle business agility
- Residual risks within defined tolerance limits

We do NOT accept:

- Risks that threaten business viability
- Regulatory non-compliance or legal exposure
- Reputational damage exceeding recovery capability
- Risks to customer trust or safety
- Risks without identified owners or mitigation plans

### 4.2 Risk Tolerance Levels

| Risk Category | Tolerance Threshold | Action Required |
|---------------|--------------------|-----------------|
| Financial Impact | > $5M potential loss | Immediate executive escalation |
| Regulatory | Any confirmed violation | Immediate legal notification |
| Reputational | Major public exposure | Board notification required |
| Operational | > 4-hour critical outage | Crisis management activation |
| Data Breach | > 100K records affected | Regulatory breach reporting |

## 5. Risk Assessment Methodology

### 5.1 Risk Calculation

```
Risk = Likelihood × Impact × Velocity

Where:
- Likelihood: Probability of occurrence (1-5 scale)
- Impact: Business consequence magnitude (1-5 scale)
- Velocity: Speed of escalation (1-5 scale)
```

### 5.2 Risk Scoring Matrix

| Score | Likelihood | Impact | Velocity |
|-------|------------|--------|----------|
| 1 | Rare (once per 10+ years) | Minimal | Over 30 days |
| 2 | Unlikely (once per 5-10 years) | Minor | 15-30 days |
| 3 | Possible (once per 1-5 years) | Moderate | 7-14 days |
| 4 | Likely (multiple per year) | Major | 3-7 days |
| 5 | Almost Certain (frequent) | Critical | < 3 days |

### 5.3 Risk Levels

| Risk Score | Level | Required Action | Approval |
|------------|-------|----------------|----------|
| 1-5 | Low | Accept or monitor | Security Team |
| 6-12 | Medium | Mitigate | Regional Director |
| 13-19 | High | Immediate mitigation | CISO |
| 20-25 | Critical | Emergency response | Executive Committee |

### 5.4 Risk Assessment Process

**Phase 1: Identification**
1. Asset inventory review
2. Threat assessment
3. Vulnerability analysis
4. Third-party risk assessment

**Phase 2: Analysis**
1. Determine potential impact
2. Assess likelihood
3. Consider existing controls
4. Calculate risk score

**Phase 3: Evaluation**
1. Compare to risk appetite
2. Prioritize risks
3. Identify treatment options

**Phase 4: Treatment**
1. Select appropriate response:
   - **Accept**: No action (within appetite)
   - **Mitigate**: Implement controls
   - **Transfer**: Insurance, vendor agreements
   - **Avoid**: Stop the activity
2. Document decision rationale
3. Assign owner and timeline

**Phase 5: Monitoring**
1. Track risk status
2. Review control effectiveness
3. Reassess periodically
4. Report to governance committees

## 6. Risk Register

### 6.1 Required Fields

| Field | Description | Example |
|-------|-------------|---------|
| Risk ID | Unique identifier | RISK-2024-001 |
| Risk Owner | Person accountable | Business Unit Head |
| Description | Clear risk statement | "Unauthorized access to customer PII" |
| Category | Risk type (e.g., compliance, operational) | Data Security |
| Likelihood | Probability score (1-5) | 3 |
| Impact | Business impact score (1-5) | 4 |
| Velocity | Speed score (1-5) | 3 |
| Risk Score | Combined score (L×I×V) | 36 |
| Risk Level | Low/Medium/High/Critical | High |
| Controls | Existing controls | MFA, encryption |
| Action Plan | Mitigation steps | Deploy DLP |
| Timeline | Target completion | Q3 2024 |
| Status | Open/In Progress/Mitigated/Accepted | In Progress |

### 6.2 Risk Register Template

**File:** `01-governance/templates/risk-register.csv`

```csv
Risk ID,Risk Owner,Description,Category,Likelihood,Impact,Velocity,Risk Score,Risk Level,Existing Controls,Action Plan,Timeline,Status,Last Review
RISK-2024-001,CIO,Unauthorized access to customer PII,Data Security,3,4,3,36,High,MFA, RBAC,Data Discovery and Classification,Implement DLP and data masking,Q3 2024,In Progress,2024-03-01
RISK-2024-002,CISO,Ransomware impact on critical systems,Operational,4,5,4,80,Critical,EDR, Immutable backups,Air-gapped backups and EDR upgrade,Q2 2024,In Progress,2024-03-01
RISK-2024-003,BUH,Supply chain software vulnerability,Third-party,3,3,3,27,Medium,SBOM scanning,Vendor security program implementation,Q4 2024,Open,2024-03-01
RISK-2024-004,CLO,GDPR non-compliance in EU operations,Compliance,2,5,2,20,High,Data classification,GDPR control implementation,Q3 2024,Open,2024-03-01
```

## 7. Risk Reporting

### 7.1 Reporting Cadence

| Report Type | Audience | Frequency |
|-------------|----------|-----------|
| Risk Register | Security Team | Weekly |
| Risk Dashboard | Executive Council | Monthly |
| Risk Summary | Board Committee | Quarterly |
| Annual Risk Report | Full Board | Annually |

### 7.2 Key Risk Indicators (KRIs)

| Indicator | Threshold | Escalation |
|-----------|-----------|------------|
| Number of open high/critical risks | > 10 | CISO |
| Average risk remediation time | > 90 days | Executive Council |
| Third-party risk exceptions | > 5% of vendors | Procurement |
| Regulatory findings | Any open finding | CLO |
| Security incident frequency | > 2 per month | Executive Council |
```

#### 2.2 Create the Risk Calculation Script

**The Target:** Create a Python script that automates risk calculations and generates risk reports.

**The Concept:** Rather than manually calculating risk scores, we'll create a tool that does it consistently and generates reports for different audiences.

**File:** `01-governance/scripts/risk_calculator.py`

```python
#!/usr/bin/env python3
"""
Enterprise Risk Calculator

This module automates the calculation and reporting of cybersecurity risks
following the enterprise risk management framework.
"""

import json
import csv
import datetime
from enum import Enum
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional
import argparse
import os


class RiskLevel(Enum):
    """Risk level categories based on NIST CSF."""
    CRITICAL = "Critical"
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"


class RiskCategory(Enum):
    """Risk categories aligned with ISO/IEC 27001."""
    GOVERNANCE = "Governance"
    COMPLIANCE = "Compliance"
    DATA_SECURITY = "Data Security"
    OPERATIONAL = "Operational"
    THIRD_PARTY = "Third-Party"
    PHYSICAL = "Physical"
    FINANCIAL = "Financial"
    REPUTATIONAL = "Reputational"


class RiskStatus(Enum):
    """Current status of risk treatment."""
    OPEN = "Open"
    IN_PROGRESS = "In Progress"
    MITIGATED = "Mitigated"
    ACCEPTED = "Accepted"
    AVOIDED = "Avoided"
    TRANSFERRED = "Transferred"


@dataclass
class Risk:
    """
    Dataclass representing a single risk entry.
    
    Attributes:
        risk_id: Unique identifier (e.g., RISK-2024-001)
        owner: Person accountable for the risk
        description: Clear description of the risk
        category: Risk category from RiskCategory enum
        likelihood: Probability score 1-5
        impact: Business impact score 1-5
        velocity: Speed of escalation 1-5
        existing_controls: Current controls in place
        action_plan: Planned mitigation steps
        timeline: Target completion date
        status: Current status from RiskStatus enum
        last_review: Date of last review
        comments: Additional notes
    """
    risk_id: str
    owner: str
    description: str
    category: str
    likelihood: int
    impact: int
    velocity: int
    existing_controls: str
    action_plan: str
    timeline: str
    status: str
    last_review: str
    comments: str = ""

    def __post_init__(self):
        """Validate field values after initialization."""
        if not (1 <= self.likelihood <= 5):
            raise ValueError("Likelihood must be between 1 and 5")
        if not (1 <= self.impact <= 5):
            raise ValueError("Impact must be between 1 and 5")
        if not (1 <= self.velocity <= 5):
            raise ValueError("Velocity must be between 1 and 5")

    def calculate_raw_score(self) -> int:
        """
        Calculate the raw risk score using the formula: Likelihood × Impact × Velocity.
        
        Returns:
            Integer risk score (1-125)
        """
        return self.likelihood * self.impact * self.velocity

    def get_risk_level(self) -> RiskLevel:
        """
        Determine risk level based on raw score.
        
        Returns:
            RiskLevel enum value
        """
        score = self.calculate_raw_score()
        if score >= 60:
            return RiskLevel.CRITICAL
        elif score >= 30:
            return RiskLevel.HIGH
        elif score >= 10:
            return RiskLevel.MEDIUM
        else:
            return RiskLevel.LOW

    def to_dict(self) -> Dict:
        """Convert Risk to dictionary for serialization."""
        risk_dict = asdict(self)
        risk_dict['raw_score'] = self.calculate_raw_score()
        risk_dict['risk_level'] = self.get_risk_level().value
        return risk_dict


class RiskManager:
    """
    Manages risk registers and performs operations on risks.
    
    This class handles CRUD operations, reporting, and analytics
    for the enterprise risk management program.
    """
    
    def __init__(self, risks: Optional[List[Risk]] = None):
        """
        Initialize the risk manager with an optional risk list.
        
        Args:
            risks: Initial list of Risk objects
        """
        self.risks = risks or []
        self._risk_index = {risk.risk_id: risk for risk in self.risks}

    def add_risk(self, risk: Risk) -> None:
        """
        Add a new risk to the register.
        
        Args:
            risk: Risk object to add
        """
        if risk.risk_id in self._risk_index:
            raise ValueError(f"Risk ID {risk.risk_id} already exists")
        self.risks.append(risk)
        self._risk_index[risk.risk_id] = risk

    def get_risk(self, risk_id: str) -> Optional[Risk]:
        """
        Retrieve a risk by its ID.
        
        Args:
            risk_id: Unique risk identifier
            
        Returns:
            Risk object or None if not found
        """
        return self._risk_index.get(risk_id)

    def update_risk(self, risk_id: str, **kwargs) -> bool:
        """
        Update risk fields.
        
        Args:
            risk_id: Risk to update
            **kwargs: Fields to update
            
        Returns:
            True if successful, False if risk not found
        """
        risk = self.get_risk(risk_id)
        if not risk:
            return False
        
        # Update allowed fields
        allowed_fields = {
            'owner', 'description', 'category', 'likelihood',
            'impact', 'velocity', 'existing_controls', 'action_plan',
            'timeline', 'status', 'last_review', 'comments'
        }
        
        for key, value in kwargs.items():
            if key in allowed_fields:
                setattr(risk, key, value)
        
        return True

    def delete_risk(self, risk_id: str) -> bool:
        """
        Remove a risk from the register.
        
        Args:
            risk_id: Risk to delete
            
        Returns:
            True if deleted, False if not found
        """
        risk = self.get_risk(risk_id)
        if not risk:
            return False
        
        self.risks.remove(risk)
        del self._risk_index[risk_id]
        return True

    def get_summary_stats(self) -> Dict:
        """
        Generate summary statistics for the risk register.
        
        Returns:
            Dictionary with risk statistics
        """
        if not self.risks:
            return {
                'total_risks': 0,
                'by_level': {level.value: 0 for level in RiskLevel},
                'by_status': {status.value: 0 for status in RiskStatus},
                'by_category': {category.value: 0 for category in RiskCategory},
                'avg_score': 0,
                'highest_score': None,
                'open_critical': 0
            }
        
        stats = {
            'total_risks': len(self.risks),
            'by_level': {level.value: 0 for level in RiskLevel},
            'by_status': {status.value: 0 for status in RiskStatus},
            'by_category': {category.value: 0 for category in RiskCategory},
            'scores': [],
            'open_critical': 0
        }
        
        for risk in self.risks:
            level = risk.get_risk_level()
            stats['by_level'][level.value] += 1
            
            status_value = risk.status
            if status_value in stats['by_status']:
                stats['by_status'][status_value] += 1
            
            category_value = risk.category
            if category_value in stats['by_category']:
                stats['by_category'][category_value] += 1
            
            score = risk.calculate_raw_score()
            stats['scores'].append(score)
            
            if status_value == 'Open' and level == RiskLevel.CRITICAL:
                stats['open_critical'] += 1
        
        stats['avg_score'] = sum(stats['scores']) / len(stats['scores']) if stats['scores'] else 0
        stats['highest_score'] = max(stats['scores']) if stats['scores'] else None
        
        return stats

    def get_risks_by_level(self, level: RiskLevel) -> List[Risk]:
        """
        Get all risks at a specific risk level.
        
        Args:
            level: RiskLevel to filter by
            
        Returns:
            List of risks at that level
        """
        return [risk for risk in self.risks if risk.get_risk_level() == level]

    def get_risks_by_status(self, status: RiskStatus) -> List[Risk]:
        """
        Get all risks with a specific status.
        
        Args:
            status: RiskStatus to filter by
            
        Returns:
            List of risks with that status
        """
        return [risk for risk in self.risks if risk.status == status.value]

    def generate_dashboard_report(self) -> str:
        """
        Generate a markdown dashboard report for executive consumption.
        
        Returns:
            Markdown formatted report
        """
        stats = self.get_summary_stats()
        date_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
        
        report = f"""
# Cybersecurity Risk Dashboard
*Report Generated: {date_str}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Risks | {stats['total_risks']} |
| Average Risk Score | {stats['avg_score']:.1f} |
| Highest Risk Score | {stats['highest_score'] or 'N/A'} |
| Open Critical Risks | {stats['open_critical']} |

## Risk Distribution

### By Risk Level

| Level | Count |
|-------|-------|
"""
        
        for level, count in stats['by_level'].items():
            report += f"| {level} | {count} |\n"
        
        report += """
### By Status

| Status | Count |
|--------|-------|
"""
        
        for status, count in stats['by_status'].items():
            if count > 0:
                report += f"| {status} | {count} |\n"
        
        report += """
### By Category

| Category | Count |
|----------|-------|
"""
        
        for category, count in stats['by_category'].items():
            if count > 0:
                report += f"| {category} | {count} |\n"
        
        report += "\n## Top 5 Highest Risks\n\n"
        sorted_risks = sorted(self.risks, key=lambda r: r.calculate_raw_score(), reverse=True)
        top_risks = sorted_risks[:5]
        
        if top_risks:
            report += "| ID | Description | Owner | Score | Level | Status |\n"
            report += "|----|-------------|-------|-------|-------|--------|\n"
            for risk in top_risks:
                report += f"| {risk.risk_id} | {risk.description[:40]}... | {risk.owner} | {risk.calculate_raw_score()} | {risk.get_risk_level().value} | {risk.status} |\n"
        else:
            report += "*No risks identified*\n"
        
        report += f"\n*Risk register contains {stats['total_risks']} identified risks as of {date_str}*\n"
        
        return report

    def to_json(self) -> str:
        """
        Export risk register as JSON.
        
        Returns:
            JSON string representation of all risks
        """
        return json.dumps([risk.to_dict() for risk in self.risks], indent=2)

    def to_csv(self, filename: str) -> None:
        """
        Export risk register to CSV.
        
        Args:
            filename: Output CSV file path
        """
        if not self.risks:
            return
        
        fieldnames = [
            'risk_id', 'owner', 'description', 'category',
            'likelihood', 'impact', 'velocity', 'existing_controls',
            'action_plan', 'timeline', 'status', 'last_review', 'comments'
        ]
        
        with open(filename, 'w', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            for risk in self.risks:
                writer.writerow(asdict(risk))

    @classmethod
    def from_csv(cls, filename: str) -> 'RiskManager':
        """
        Load risks from CSV file.
        
        Args:
            filename: CSV file path
            
        Returns:
            RiskManager instance with loaded risks
        """
        risks = []
        with open(filename, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                risk = Risk(
                    risk_id=row['risk_id'],
                    owner=row['owner'],
                    description=row['description'],
                    category=row['category'],
                    likelihood=int(row['likelihood']),
                    impact=int(row['impact']),
                    velocity=int(row['velocity']),
                    existing_controls=row['existing_controls'],
                    action_plan=row['action_plan'],
                    timeline=row['timeline'],
                    status=row['status'],
                    last_review=row['last_review'],
                    comments=row.get('comments', '')
                )
                risks.append(risk)
        return cls(risks)


def main():
    """Command-line interface for risk management."""
    parser = argparse.ArgumentParser(
        description='Enterprise Cybersecurity Risk Management Tool'
    )
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Create subcommand for loading CSV
    load_parser = subparsers.add_parser('load', help='Load risks from CSV')
    load_parser.add_argument('filename', help='Input CSV file path')
    
    # Dashboard report command
    dashboard_parser = subparsers.add_parser('dashboard', help='Generate dashboard report')
    dashboard_parser.add_argument('--input', '-i', help='Input CSV file path')
    dashboard_parser.add_argument('--output', '-o', default='dashboard.md', help='Output report file')
    
    # Export command
    export_parser = subparsers.add_parser('export', help='Export risk register')
    export_parser.add_argument('--input', '-i', help='Input CSV file path')
    export_parser.add_argument('--output', '-o', default='risks.json', help='Output JSON file')
    
    # Add risk command
    add_parser = subparsers.add_parser('add', help='Add a new risk interactively')
    add_parser.add_argument('--interactive', '-i', action='store_true', help='Interactive mode')
    add_parser.add_argument('--file', '-f', help='Load from JSON file')
    
    args = parser.parse_args()
    
    if args.command == 'load':
        manager = RiskManager.from_csv(args.filename)
        print(f"✅ Loaded {len(manager.risks)} risks from {args.filename}")
        print("\nSummary:")
        stats = manager.get_summary_stats()
        print(f"  - Total: {stats['total_risks']}")
        print(f"  - Open Critical: {stats['open_critical']}")
        print(f"  - Average Score: {stats['avg_score']:.1f}")
        
    elif args.command == 'dashboard':
        if args.input:
            manager = RiskManager.from_csv(args.input)
        else:
            # Try loading default risk register
            if os.path.exists('risk-register.csv'):
                manager = RiskManager.from_csv('risk-register.csv')
            else:
                # Create sample risks
                manager = RiskManager()
                manager.add_risk(Risk(
                    risk_id='RISK-2024-001',
                    owner='CIO',
                    description='Unauthorized access to customer PII',
                    category='Data Security',
                    likelihood=3,
                    impact=4,
                    velocity=3,
                    existing_controls='MFA, RBAC',
                    action_plan='Implement DLP and data masking',
                    timeline='Q3 2024',
                    status='In Progress',
                    last_review='2024-03-01'
                ))
                manager.add_risk(Risk(
                    risk_id='RISK-2024-002',
                    owner='CISO',
                    description='Ransomware impact on critical systems',
                    category='Operational',
                    likelihood=4,
                    impact=5,
                    velocity=4,
                    existing_controls='EDR, Immutable backups',
                    action_plan='Air-gapped backups and EDR upgrade',
                    timeline='Q2 2024',
                    status='In Progress',
                    last_review='2024-03-01'
                ))
                manager.add_risk(Risk(
                    risk_id='RISK-2024-003',
                    owner='BUH',
                    description='Supply chain software vulnerability',
                    category='Third-Party',
                    likelihood=3,
                    impact=3,
                    velocity=3,
                    existing_controls='SBOM scanning',
                    action_plan='Vendor security program implementation',
                    timeline='Q4 2024',
                    status='Open',
                    last_review='2024-03-01'
                ))
                manager.add_risk(Risk(
                    risk_id='RISK-2024-004',
                    owner='CLO',
                    description='GDPR non-compliance in EU operations',
                    category='Compliance',
                    likelihood=2,
                    impact=5,
                    velocity=2,
                    existing_controls='Data classification',
                    action_plan='GDPR control implementation',
                    timeline='Q3 2024',
                    status='Open',
                    last_review='2024-03-01'
                ))
        
        report = manager.generate_dashboard_report()
        with open(args.output, 'w') as f:
            f.write(report)
        print(f"✅ Dashboard report saved to {args.output}")
        print("\n" + report)
        
    elif args.command == 'export':
        if args.input:
            manager = RiskManager.from_csv(args.input)
        else:
            if os.path.exists('risk-register.csv'):
                manager = RiskManager.from_csv('risk-register.csv')
            else:
                print("❌ No risk register found. Use 'load' first.")
                return
        
        with open(args.output, 'w') as f:
            f.write(manager.to_json())
        print(f"✅ Risk register exported to {args.output}")
        
    elif args.command == 'add':
        print("Interactive risk entry mode")
        print("-" * 50)
        
        risk_id = input("Risk ID (e.g., RISK-2024-005): ")
        owner = input("Risk Owner: ")
        description = input("Risk Description: ")
        
        print("\nCategory options:")
        for i, cat in enumerate(RiskCategory, 1):
            print(f"  {i}. {cat.value}")
        category_idx = int(input("Select category (1-7): ")) - 1
        category = list(RiskCategory)[category_idx].value
        
        likelihood = int(input("Likelihood (1-5): "))
        impact = int(input("Impact (1-5): "))
        velocity = int(input("Velocity (1-5): "))
        
        existing_controls = input("Existing Controls: ")
        action_plan = input("Action Plan: ")
        timeline = input("Timeline (e.g., Q3 2024): ")
        
        print("\nStatus options:")
        for i, status in enumerate(RiskStatus, 1):
            print(f"  {i}. {status.value}")
        status_idx = int(input("Select status (1-6): ")) - 1
        status = list(RiskStatus)[status_idx].value
        
        last_review = input("Last Review Date (YYYY-MM-DD): ")
        comments = input("Comments (optional): ")
        
        risk = Risk(
            risk_id=risk_id,
            owner=owner,
            description=description,
            category=category,
            likelihood=likelihood,
            impact=impact,
            velocity=velocity,
            existing_controls=existing_controls,
            action_plan=action_plan,
            timeline=timeline,
            status=status,
            last_review=last_review,
            comments=comments
        )
        
        manager = RiskManager()
        manager.add_risk(risk)
        
        print("\n✅ Risk added successfully!")
        print(f"   Score: {risk.calculate_raw_score()}")
        print(f"   Level: {risk.get_risk_level().value}")
        
        # Save to CSV
        manager.to_csv('risk-register.csv')
        print("✅ Risk saved to risk-register.csv")
        
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

**File:** `01-governance/scripts/requirements.txt`

```
# Risk Calculator Dependencies
# Install with: pip install -r requirements.txt

typing-extensions>=4.0.0
```

### Step 3: Create Security Policies

**The Target:** Develop the core security policies that define organizational security requirements.

**The Concept:** Think of security policies like the rulebook for your organization. They establish what's required, what's prohibited, and what happens when rules are broken. Good policies are:

- **Clear**: Easy to understand
- **Comprehensive**: Cover all critical areas
- **Enforceable**: Can be monitored and enforced
- **Practical**: Balance security with business needs

#### 3.1 Information Security Policy

**File:** `01-governance/policies/information-security-policy.md`

```markdown
---
title: Enterprise Information Security Policy
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Annual
---

# Enterprise Information Security Policy

## 1. Purpose

The purpose of this policy is to establish the fundamental security principles and requirements for protecting [Organization Name]'s information assets across all global operations, ensuring confidentiality, integrity, and availability of information.

## 2. Scope

This policy applies to:
- All employees, contractors, interns, and temporary staff globally
- All third parties accessing organizational information or systems
- All information assets, regardless of classification or format
- All systems and networks, including cloud, on-premises, and hybrid
- All business processes and operations

## 3. Information Security Principles

### 3.1 Confidentiality
Information is accessible only to authorized individuals, processes, or systems with a legitimate need.

### 3.2 Integrity
Information is accurate, complete, and protected from unauthorized modification.

### 3.3 Availability
Information and systems are accessible and usable when needed by authorized users.

## 4. Security Requirements

### 4.1 Access Control
- All access to organizational resources requires authentication
- Access is granted based on the principle of least privilege
- Multi-factor authentication is required for all privileged access
- Access rights are reviewed quarterly

### 4.2 Data Protection
- Data classification determines protection requirements
- Personal data is protected in accordance with privacy regulations
- Encryption is required for data at rest and in transit
- Data retention follows legal and business requirements

### 4.3 Network Security
- Networks are segmented to limit unauthorized access
- All network devices are securely configured
- Remote access requires VPN or secure remote access solutions
- Network monitoring identifies suspicious activity

### 4.4 Endpoint Security
- All endpoints require antivirus and EDR protection
- Operating systems and applications are patched within SLA
- Unauthorized software installation is prohibited
- Endpoints are encrypted and securely configured

### 4.5 Incident Response
- All security incidents are reported and investigated
- Incident response procedures are documented and tested
- Lessons learned are incorporated into security improvements

### 4.6 Business Continuity
- Critical systems have documented recovery procedures
- Regular backups are maintained and tested
- Business continuity plans are tested annually

### 4.7 Third-Party Security
- Third parties undergo security assessments before access
- Contracts include security requirements
- Third-party access is monitored and reviewed
- Service levels include security metrics

## 5. Roles and Responsibilities

### 5.1 Information Security Team
- Develop and maintain security policies and standards
- Conduct security assessments and audits
- Monitor security controls and respond to incidents
- Provide security guidance and training

### 5.2 Business Unit Leaders
- Ensure compliance with security policies in their units
- Allocate resources for security controls
- Manage risk within their areas
- Report security incidents promptly

### 5.3 IT Operations
- Implement and maintain security controls
- Apply patches and updates
- Manage identity and access
- Support incident response

### 5.4 All Employees
- Comply with all security policies
- Protect information assets
- Report security incidents
- Complete required security training

## 6. Policy Compliance

### 6.1 Compliance Monitoring
- Regular security assessments and audits
- Continuous monitoring of security controls
- Automated compliance checks where possible
- Annual internal and external audits

### 6.2 Non-Compliance Consequences
Non-compliance with this policy may result in:
- Disciplinary action, up to termination
- Loss of access privileges
- Legal consequences
- Financial penalties

### 6.3 Exceptions
Exceptions to this policy must be:
- Documented in writing
- Approved by the CISO
- Reviewed quarterly
- Time-limited

## 7. Policy Reviews

This policy will be reviewed:
- Annually for continued relevance
- After major security incidents
- Following significant regulatory changes
- As business or technology changes require

## 8. Attachments

### 8.1 Related Policies
- Access Control Policy
- Acceptable Use Policy
- Data Classification Policy
- Incident Response Policy
- Business Continuity Policy
- Third-Party Security Policy

### 8.2 Control Mapping

| NIST CSF 2.0 | ISO/IEC 27001 | This Policy |
|--------------|---------------|-------------|
| GOVERN (GV) | 5 (Leadership) | Section 5 |
| IDENTIFY (ID) | 6 (Planning) | Section 4 |
| PROTECT (PR) | 8 (Operations) | Section 4 |
| DETECT (DE) | 7 (Support) | Section 4.5 |
| RESPOND (RS) | 8.7 (Incidents) | Section 4.5 |
| RECOVER (RC) | 8.8 (Continuity) | Section 4.6 |
```

#### 3.2 Create Supporting Policies

**File:** `01-governance/policies/access-control-policy.md`

```markdown
---
title: Access Control Policy
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Bi-annual
---

# Access Control Policy

## 1. Purpose

This policy establishes access control requirements to ensure that access to organizational information and systems is appropriately managed, consistent with business needs and risk profile.

## 2. Scope

All systems, applications, data, and users within [Organization Name].

## 3. Access Control Principles

### 3.1 Least Privilege
Users are granted the minimum access required to perform their job functions. Privileges are not "nice to have"—they are strictly necessary.

### 3.2 Need-to-Know
Access to sensitive information is granted only when there is a legitimate business need.

### 3.3 Separation of Duties
Critical functions are divided among multiple individuals to prevent fraud or errors.

### 3.4 Just-in-Time Access
Privileged access is granted only when needed and for the minimum required duration.

## 4. Access Control Requirements

### 4.1 User Authentication

| Requirement | Standard |
|-------------|----------|
| Password complexity | Minimum 12 characters, including uppercase, lowercase, numbers, symbols |
| Password history | Last 24 passwords remembered |
| Password aging | Maximum 90 days |
| Account lockout | After 5 failed attempts, locked for 15 minutes |
| MFA | Required for all external access, privileged access, and critical systems |
| Passwordless | Evaluation and implementation of passwordless options |

### 4.2 User Provisioning

| Process | Requirement |
|---------|-------------|
| Account creation | Automated through HR integration |
| Access requests | Workflow-based with approvals |
| Account modification | Triggered by role changes |
| Account deactivation | Within 24 hours of termination |
| Access recertification | Quarterly for all access |

### 4.3 Privileged Access Management

| Requirement | Standard |
|-------------|----------|
| PAM system | Mandatory for all privileged accounts |
| Credential vaulting | All privileged credentials stored in vault |
| Session recording | Recorded for all privileged sessions |
| Just-in-time access | Privileges elevated only for specific tasks |
| Break-glass access | Emergency access documented and audited |

### 4.4 Access Reviews

| Type | Frequency | Responsibility |
|------|-----------|----------------|
| User access | Quarterly | Business unit managers |
| Privileged access | Monthly | Security team |
| Application access | Quarterly | Application owners |
| Vendor access | Monthly | Procurement/security |
| System accounts | Monthly | IT Operations |

## 5. Remote Access

### 5.1 VPN Requirements
- VPN required for all remote access
- MFA required for VPN connections
- Session timeout after 8 hours of inactivity
- Split-tunneling restricted for sensitive applications

### 5.2 Secure Remote Access
- Zero Trust Network Access (ZTNA) preferred
- Application-specific access policies
- Device posture checking required

## 6. Third-Party Access

- Vendor access requires business justification
- Access limited to minimum required
- MFA required for all third-party access
- Vendor access reviewed monthly
- Contracts include access requirements

## 7. Audit and Monitoring

### 7.1 Monitoring Requirements
- All access attempts logged
- Failed authentication attempts logged and alerted
- Privileged access audited
- Access changes tracked with audit trail

### 7.2 Alerting
- Multiple failed authentication attempts: Alert security team
- Unusual access patterns: Alert SOC
- Privileged access outside business hours: Alert security team
- Access from unusual locations: Alert SOC

## 8. Roles and Responsibilities

| Role | Responsibility |
|------|----------------|
| User | Protect credentials, follow access procedures, report issues |
| Manager | Approve access requests, conduct access reviews |
| IT Operations | Provision access, maintain access controls |
| Security Team | Define policies, monitor compliance, investigate violations |
| CISO | Approve policy exceptions |

## 9. Exceptions

Exceptions to this policy require:
- Written justification
- Business unit head approval
- CISO approval
- Quarterly review
```

**File:** `01-governance/policies/acceptable-use-policy.md`

```markdown
---
title: Acceptable Use Policy
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Annual
---

# Acceptable Use Policy

## 1. Purpose

This policy defines acceptable and unacceptable use of organizational resources to protect information assets, maintain productivity, and ensure compliance.

## 2. Scope

All users of organizational resources, including employees, contractors, interns, and third parties.

## 3. Acceptable Use

### 3.1 Permitted Activities
- Conducting organizational business
- Collaborating with colleagues and partners
- Accessing information needed for work
- Using approved productivity tools
- Professional development and training

### 3.2 Personal Use
- Limited personal use is permitted
- Must not interfere with work
- Must not violate any laws
- Must not consume excessive resources

## 4. Unacceptable Use

### 4.1 Prohibited Activities
- Unauthorized access to systems or data
- Accessing, storing, or transmitting:
  - Pornographic material
  - Copyrighted material without permission
  - Offensive or discriminatory content
  - Malware or hacking tools
  - Personal data without authorization
- Engaging in illegal activities
- Harassment or bullying
- Commercial activities outside organization

### 4.2 System Misuse
- Installing unauthorized software
- Bypassing security controls
- Sharing credentials
- Using personal devices without authorization
- Running unauthorized services

## 5. BYOD (Bring Your Own Device)

### 5.1 Requirements
- Device must be enrolled in MDM
- Minimum OS security patches
- Screen lock required
- Encryption required
- Personal and corporate data separated

### 5.2 Restrictions
- No access to sensitive data without approval
- Must use MFA for all access
- Remote wipe capability required
- Compliance with data protection laws

## 6. Monitoring and Enforcement

### 6.1 Monitoring
- Limited to security and compliance purposes
- Privacy considerations respected
- Transparency with workforce

### 6.2 Enforcement
- Violations investigated by security team
- Disciplinary action based on severity
- Legal action for serious violations
- Reporting to management

## 7. Acknowledgment

All users must acknowledge this policy annually.
```

### Step 4: Create the Cybersecurity Strategy and Roadmap

**The Target:** Develop a 3-year cybersecurity strategy roadmap.

**The Concept:** A strategy is like a GPS for your security program. It tells you where you are, where you want to go, and how you'll get there. Good strategy:

- Aligns with business objectives
- Sets clear priorities
- Defines measurable outcomes
- Allocates resources
- Shows progress over time

**File:** `01-governance/strategy/cybersecurity-roadmap-2024-2026.md`

```markdown
---
title: Cybersecurity Strategy Roadmap 2024-2026
version: 1.0
status: Draft
approval_date: TBD
review_cycle: Bi-annual
---

# Cybersecurity Strategy Roadmap 2024-2026

## Executive Summary

This roadmap outlines [Organization Name]'s cybersecurity strategy for the next three years, aligned with our business objectives and risk appetite. The strategy focuses on building foundational capabilities in Year 1, operational excellence in Year 2, and program maturity in Year 3.

### Strategic Themes
1. **Zero Trust Architecture**: Implement continuous verification
2. **Cloud Security**: Secure multi-cloud operations
3. **Automation & AI**: Enhance detection and response
4. **Supply Chain Security**: Extend security to third parties
5. **Security Culture**: Build workforce security awareness

## Strategic Alignment

### Business Objectives
- Global expansion: Support new market entry
- Digital transformation: Enable innovation
- Customer trust: Protect brand reputation
- Operational efficiency: Minimize downtime
- Regulatory compliance: Meet global requirements

### Security Program Outcomes
- Reduced risk exposure
- Improved detection speed
- Enhanced recovery capability
- Strengthened compliance posture
- Increased program maturity

## 3-Year Roadmap

### Year 1 (2024): Foundation Building

**Theme**: Establish core capabilities and governance

| Quarter | Initiative | Success Criteria | Owner |
|---------|------------|------------------|-------|
| Q1 | Governance & Strategy | RACI approved, Risk framework operational, 10+ risk policies | CISO |
| Q2 | Asset Discovery | 95% asset visibility, Data classification program, CMDB | Security Team |
| Q3 | Identity & Access | MFA deployment, PAM implementation, Access reviews | IAM Lead |
| Q4 | Foundational Controls | EDR deployment, Network segmentation, Encryption at rest | Security Architecture |

**Key Deliverables**:
- Executive Governance Charter
- RACI Matrix
- Risk Register
- Asset Inventory
- Data Classification Policy
- MFA Implementation
- EDR Deployment
- Network Segmentation

### Year 2 (2025): Operational Excellence

**Theme**: Enhance and automate security operations

| Quarter | Initiative | Success Criteria | Owner |
|---------|------------|------------------|-------|
| Q1 | Detection & Response | SOC operations, SIEM implementation, 3 playbooks | SOC Lead |
| Q2 | BCP & DR | Recovery plans, 10+ system recovery, Immutable backups | IT Operations |
| Q3 | Cloud Security | CSPM implementation, 90% cloud workload visibility | Cloud Security |
| Q4 | Third-Party Security | Vendor risk program, SBOM management | Procurement |

**Key Deliverables**:
- 24/7 SOC Coverage
- Incident Response Playbooks
- Business Continuity Plans
- Immutable Backup Strategy
- CSPM Monitoring
- Vendor Risk Scorecards
- SBOM Governance

### Year 3 (2026): Program Maturity

**Theme**: Continuous improvement and innovation

| Quarter | Initiative | Success Criteria | Owner |
|---------|------------|------------------|-------|
| Q1 | Security Culture | 100% awareness training, Phishing simulation program | HR/Security |
| Q2 | Automation & AI | AI-assisted detection, Automated response | Security Engineering |
| Q3 | Maturity Assessment | Level 3 maturity, 90% NIST CSF coverage | CISO |
| Q4 | Continuous Improvement | KPI dashboards, Annual improvement plan | CISO |

**Key Deliverables**:
- Security Awareness Program
- Phishing Simulation Platform
- AI Security Operations
- Maturity Assessment
- KPI Dashboard
- Continuous Improvement Program

## Investment Plan

### Budget Allocation

| Year | Operating Budget | Capital Investment | Total |
|------|------------------|-------------------|-------|
| 2024 | $3.2M | $4.5M | $7.7M |
| 2025 | $4.1M | $3.8M | $7.9M |
| 2026 | $4.8M | $2.5M | $7.3M |

**Total 3-Year Investment**: $22.9M

### Resource Plan

| Role | Year 1 | Year 2 | Year 3 |
|------|--------|--------|--------|
| Security Team | 15 | 22 | 28 |
| Contractors | 5 | 3 | 2 |
| Managed Services | Partial | Full | Full |

## Success Metrics

### Key Performance Indicators (KPIs)

| KPI | Baseline | Year 1 | Year 2 | Year 3 |
|-----|----------|--------|--------|--------|
| Risk Score (Avg) | 35 | 25 | 18 | 12 |
| MFA Adoption | 40% | 90% | 95% | 98% |
| Incident MTTR | 72 hrs | 24 hrs | 8 hrs | 4 hrs |
| Vulnerability Age | 90 days | 30 days | 14 days | 7 days |
| Program Maturity (CMMI) | Level 1 | Level 2 | Level 3 | Level 4 |

### Key Risk Indicators (KRIs)

| KRI | Threshold | Target |
|-----|-----------|--------|
| Open Critical Risks | >3 | 0 |
| Compliance Findings | >5 | 0 |
| Third-Party Risk Score | >60 | <40 |
| Unpatched Vulnerabilities | >100 | <10 |

## Risk Management Strategy

### Risk Appetite by Domain

| Domain | Risk Appetite | Rationale |
|--------|--------------|-----------|
| Data Security | Low | Customer trust is paramount |
| Compliance | Very Low | Regulatory scrutiny high |
| Operational | Moderate | Business agility required |
| Innovation | Moderate-High | Competitive advantage |
| Third-Party | Low | Supply chain is critical |

### Risk Mitigation Priorities

1. **Identity Security**: Prevent unauthorized access
2. **Data Protection**: Protect sensitive information
3. **Resilience**: Ensure business continuity
4. **Supply Chain**: Secure extended enterprise
5. **Compliance**: Meet regulatory requirements

## Continuous Improvement

### Maturity Journey

```
Level 1: Initial (Reactive)
   ↓
Level 2: Repeatable (Standardized)
   ↓
Level 3: Defined (Documented)
   ↓
Level 4: Managed (Measured)
   ↓
Level 5: Optimizing (Continuous)
```

### Improvement Cycle

1. **Assess**: Current state assessment
2. **Plan**: Identify gaps and priorities
3. **Implement**: Execute improvement initiatives
4. **Measure**: Track progress and outcomes
5. **Review**: Lessons learned and adjust

## Governance

### Review Cadence

| Review | Frequency | Participants |
|--------|-----------|--------------|
| Progress Review | Monthly | Executive Council |
| Strategy Review | Quarterly | Security Committee |
| Annual Review | Annually | Board Committee |

### Escalation Path

```
CISO
  ↓ (Monthly)
Executive Cybersecurity Council
  ↓ (Quarterly)
Board Cybersecurity Committee
  ↓ (Annually)
Full Board of Directors
```

## Appendix: Initiative Details

### Initiative: Zero Trust Architecture (Q3-Q4 2024)

**Objectives**:
- Implement continuous verification
- Reduce implicit trust
- Improve access controls

**Components**:
1. Identity verification (MFA)
2. Device posture checking
3. Network micro-segmentation
4. Application-level access
5. Continuous monitoring

### Initiative: Incident Response Program (Q1-Q3 2025)

**Objectives**:
- Reduce incident response time
- Improve detection accuracy
- Enhance recovery capability

**Components**:
1. SOC Operations
2. Incident Response Playbooks
3. Tabletop Exercises
4. Forensic Capabilities
5. Lessons Learned Program

### Initiative: Security Culture (Q1-Q4 2026)

**Objectives**:
- Increase security awareness
- Improve reporting
- Build security champions

**Components**:
1. Annual Training Program
2. Phishing Simulations
3. Security Champions
4. Recognition Program
5. Continuous Education

## Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| CISO | [Name] | ________ | [Date] |
| CFO | [Name] | ________ | [Date] |
| CEO | [Name] | ________ | [Date] |
| Board Chair | [Name] | ________ | [Date] |
```

### Step 5: Implement the Risk Register

**The Target:** Create a working risk register using the Python risk calculator tool.

**The Concept:** Instead of managing risks in spreadsheets, we'll use a combination of structured data and automation to make risk management scalable and reliable.

#### 5.1 Set up the Risk Register

**The Implementation:**

```bash
# Create the risk register directory
mkdir -p 01-governance/risk-register

# Navigate to the scripts directory
cd 01-governance/scripts

# Create the sample risk register CSV
cat > 01-governance/risk-register/risk-register.csv << EOF
risk_id,owner,description,category,likelihood,impact,velocity,existing_controls,action_plan,timeline,status,last_review,comments
RISK-2024-001,CIO,Unauthorized access to customer PII,Data Security,3,4,3,"MFA, RBAC, Access logs","Implement DLP, Data masking, Anomaly detection",Q3 2024,In Progress,2024-03-01,"High priority due to GDPR"
RISK-2024-002,CISO,Ransomware impact on critical systems,Operational,4,5,4,"EDR, Backups, Network segmentation","Air-gapped backups, EDR upgrade, Recovery testing",Q2 2024,In Progress,2024-03-01,"Critical systems include ERP and email"
RISK-2024-003,BUH,Supply chain software vulnerability,Third-Party,3,3,3,"SBOM scanning, Vendor assessments","Supply chain security program, Continuous monitoring",Q4 2024,Open,2024-03-01,"Log4j-like vulnerabilities"
RISK-2024-004,CLO,GDPR non-compliance in EU operations,Compliance,2,5,2,"Data classification, Privacy notices","GDPR controls implementation, DPO review",Q3 2024,Open,2024-03-01,"Potential fines up to €20M"
RISK-2024-005,CISO,Insider data exfiltration,Data Security,2,4,2,"DLP, Access controls, Monitoring","UEBA deployment, Enhanced DLP",Q2 2024,In Progress,2024-03-01,"Sensitive IP at risk"
RISK-2024-006,ITOP,Cloud misconfiguration,Operational,4,3,4,"Cloud security tools, IAM","CSPM implementation, Configuration reviews",Q2 2024,In Progress,2024-03-01,"Multi-cloud complexity"
RISK-2024-007,BUH,Loss of critical data,Operational,2,5,3,"Backups, Replication","Immutable backups, DR testing",Q3 2024,Open,2024-03-01,"Recovery RTO/RPO defined"
RISK-2024-008,CPO,Data subject access request handling,Compliance,3,3,2,"DSAR process, Documentation","Automated DSAR platform, Training",Q4 2024,Open,2024-03-01,"Increasing DSAR volume"
RISK-2024-009,CM,Inadequate patch management,Operational,4,2,3,"Patch management policy, Automation","Automated patching, Vulnerability scanning",Q3 2024,In Progress,2024-03-01,"Known vulnerabilities risk"
RISK-2024-010,PM,Vendor access abuse,Third-Party,2,3,2,"Vendor access reviews, MFA","Continuous monitoring, Access audits",Q4 2024,Open,2024-03-01,"Third-party access risk"
EOF

echo "✅ Sample risk register created at 01-governance/risk-register/risk-register.csv"
```

#### 5.2 Initialize and Test the Risk Calculator

**The Implementation:**

```bash
# Create a Python virtual environment
cd 01-governance/scripts
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies (if any)
pip install -r requirements.txt  # Or create empty requirements file

# Test the risk calculator
python3 risk_calculator.py load ../risk-register/risk-register.csv
```

#### 5.3 Generate the Dashboard Report

**The Implementation:**

```bash
# Generate the dashboard report
python3 risk_calculator.py dashboard --input ../risk-register/risk-register.csv --output ../reports/dashboard.md

# Create reports directory if it doesn't exist
mkdir -p ../reports

# View the report
cat ../reports/dashboard.md
```

#### 5.4 Export Risk Register to JSON

**The Implementation:**

```bash
# Export as JSON
python3 risk_calculator.py export --input ../risk-register/risk-register.csv --output ../reports/risk-register.json

# View the JSON
head -20 ../reports/risk-register.json
```

#### 5.5 Add a New Risk Interactively

**The Implementation:**

```bash
# Run interactive risk addition
python3 risk_calculator.py add --interactive

# The script will prompt for:
# - Risk ID (e.g., RISK-2024-011)
# - Risk Owner
# - Risk Description
# - Category
# - Likelihood (1-5)
# - Impact (1-5)
# - Velocity (1-5)
# - Existing Controls
# - Action Plan
# - Timeline
# - Status
# - Last Review Date
# - Comments (optional)
```

## Verification

Let's verify everything works as expected:

### Verification 1: Risk Register CSV Exists

**Command:**
```bash
# Check if the risk register CSV file exists
ls -la 01-governance/risk-register/risk-register.csv

# View the contents
head -5 01-governance/risk-register/risk-register.csv
```

**Expected Output:**
```
-rw-r--r--  1 user  staff  1456 Mar 15 10:00 01-governance/risk-register/risk-register.csv
risk_id,owner,description,category,likelihood,impact,velocity,existing_controls,action_plan,timeline,status,last_review,comments
RISK-2024-001,CIO,Unauthorized access to customer PII,Data Security,3,4,3,"MFA, RBAC, Access logs","Implement DLP, Data masking, Anomaly detection",Q3 2024,In Progress,2024-03-01,"High priority due to GDPR"
...
```

### Verification 2: Risk Calculator Loads Data

**Command:**
```bash
cd 01-governance/scripts
python3 risk_calculator.py load ../risk-register/risk-register.csv
```

**Expected Output:**
```
✅ Loaded 10 risks from ../risk-register/risk-register.csv

Summary:
  - Total: 10
  - Open Critical: 0
  - Average Score: 0.0
```

### Verification 3: Dashboard Report Generation

**Command:**
```bash
python3 risk_calculator.py dashboard --input ../risk-register/risk-register.csv --output ../reports/dashboard.md

cat ../reports/dashboard.md
```

**Expected Output:**
```
# Cybersecurity Risk Dashboard
*Report Generated: 2024-03-15 10:00*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Risks | 10 |
| Average Risk Score | 44.0 |
| Highest Risk Score | 80 |
| Open Critical Risks | 0 |

## Risk Distribution

### By Risk Level

| Level | Count |
|-------|-------|
| Critical | 1 |
| High | 6 |
| Medium | 3 |
| Low | 0 |
```

### Verification 4: Risk Calculator Unit Test

**The Implementation:**

Let's create a simple unit test to verify the risk calculation logic works correctly.

**File:** `01-governance/scripts/test_risk_calculator.py`

```python
#!/usr/bin/env python3
"""
Unit tests for the risk calculator module.
"""

import unittest
import tempfile
import os
from risk_calculator import Risk, RiskManager, RiskLevel


class TestRisk(unittest.TestCase):
    """Test Risk class functionality."""
    
    def test_risk_creation(self):
        """Test creating a risk with valid data."""
        risk = Risk(
            risk_id="TEST-001",
            owner="Test Owner",
            description="Test risk",
            category="Operational",
            likelihood=3,
            impact=4,
            velocity=3,
            existing_controls="None",
            action_plan="Test plan",
            timeline="Q1 2024",
            status="Open",
            last_review="2024-01-01"
        )
        self.assertEqual(risk.risk_id, "TEST-001")
        self.assertEqual(risk.calculate_raw_score(), 36)
        self.assertEqual(risk.get_risk_level(), RiskLevel.HIGH)
    
    def test_risk_invalid_likelihood(self):
        """Test that invalid likelihood raises error."""
        with self.assertRaises(ValueError):
            Risk(
                risk_id="TEST-002",
                owner="Test Owner",
                description="Invalid risk",
                category="Operational",
                likelihood=6,  # Invalid: must be 1-5
                impact=3,
                velocity=3,
                existing_controls="None",
                action_plan="Test plan",
                timeline="Q1 2024",
                status="Open",
                last_review="2024-01-01"
            )
    
    def test_risk_levels(self):
        """Test risk level calculation."""
        test_cases = [
            (1, 1, 1, RiskLevel.LOW),    # 1×1×1 = 1
            (2, 2, 2, RiskLevel.LOW),    # 2×2×2 = 8
            (2, 3, 2, RiskLevel.MEDIUM), # 2×3×2 = 12
            (3, 3, 4, RiskLevel.HIGH),   # 3×3×4 = 36
            (5, 5, 5, RiskLevel.CRITICAL) # 5×5×5 = 125
        ]
        
        for likelihood, impact, velocity, expected_level in test_cases:
            risk = Risk(
                risk_id="TEST-003",
                owner="Test",
                description="Test",
                category="Operational",
                likelihood=likelihood,
                impact=impact,
                velocity=velocity,
                existing_controls="None",
                action_plan="Test",
                timeline="Q1 2024",
                status="Open",
                last_review="2024-01-01"
            )
            self.assertEqual(risk.get_risk_level(), expected_level)


class TestRiskManager(unittest.TestCase):
    """Test RiskManager class functionality."""
    
    def setUp(self):
        """Set up test data."""
        self.risk1 = Risk(
            risk_id="TEST-001",
            owner="Owner 1",
            description="Risk 1",
            category="Operational",
            likelihood=3,
            impact=4,
            velocity=3,
            existing_controls="None",
            action_plan="Plan 1",
            timeline="Q1 2024",
            status="Open",
            last_review="2024-01-01"
        )
        self.risk2 = Risk(
            risk_id="TEST-002",
            owner="Owner 2",
            description="Risk 2",
            category="Compliance",
            likelihood=5,
            impact=5,
            velocity=4,
            existing_controls="Some",
            action_plan="Plan 2",
            timeline="Q2 2024",
            status="In Progress",
            last_review="2024-01-01"
        )
        self.manager = RiskManager([self.risk1, self.risk2])
    
    def test_add_risk(self):
        """Test adding a risk to manager."""
        risk3 = Risk(
            risk_id="TEST-003",
            owner="Owner 3",
            description="Risk 3",
            category="Data Security",
            likelihood=2,
            impact=3,
            velocity=2,
            existing_controls="Some",
            action_plan="Plan 3",
            timeline="Q3 2024",
            status="Open",
            last_review="2024-01-01"
        )
        self.manager.add_risk(risk3)
        self.assertEqual(len(self.manager.risks), 3)
        self.assertEqual(self.manager.get_risk("TEST-003"), risk3)
    
    def test_add_duplicate_risk(self):
        """Test adding duplicate risk raises error."""
        duplicate = Risk(
            risk_id="TEST-001",  # Duplicate ID
            owner="Duplicate",
            description="Duplicate risk",
            category="Operational",
            likelihood=1,
            impact=1,
            velocity=1,
            existing_controls="None",
            action_plan="Plan",
            timeline="Q1 2024",
            status="Open",
            last_review="2024-01-01"
        )
        with self.assertRaises(ValueError):
            self.manager.add_risk(duplicate)
    
    def test_get_risk(self):
        """Test retrieving a risk by ID."""
        risk = self.manager.get_risk("TEST-001")
        self.assertIsNotNone(risk)
        self.assertEqual(risk.owner, "Owner 1")
        
        # Test non-existent risk
        self.assertIsNone(self.manager.get_risk("NONEXISTENT"))
    
    def test_update_risk(self):
        """Test updating risk fields."""
        result = self.manager.update_risk(
            "TEST-001",
            owner="New Owner",
            status="Mitigated"
        )
        self.assertTrue(result)
        risk = self.manager.get_risk("TEST-001")
        self.assertEqual(risk.owner, "New Owner")
        self.assertEqual(risk.status, "Mitigated")
        
        # Test update non-existent risk
        result = self.manager.update_risk("NONEXISTENT", owner="Nobody")
        self.assertFalse(result)
    
    def test_delete_risk(self):
        """Test deleting a risk."""
        result = self.manager.delete_risk("TEST-001")
        self.assertTrue(result)
        self.assertEqual(len(self.manager.risks), 1)
        self.assertIsNone(self.manager.get_risk("TEST-001"))
        
        # Test delete non-existent risk
        result = self.manager.delete_risk("NONEXISTENT")
        self.assertFalse(result)
    
    def test_summary_stats(self):
        """Test summary statistics generation."""
        stats = self.manager.get_summary_stats()
        self.assertEqual(stats['total_risks'], 2)
        self.assertEqual(stats['by_level'][RiskLevel.CRITICAL.value], 1)
        self.assertEqual(stats['by_level'][RiskLevel.HIGH.value], 1)
        self.assertEqual(stats['by_status']['Open'], 1)
        self.assertEqual(stats['by_status']['In Progress'], 1)
    
    def test_export_import_csv(self):
        """Test CSV export and import."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            self.manager.to_csv(f.name)
            csv_file = f.name
        
        try:
            new_manager = RiskManager.from_csv(csv_file)
            self.assertEqual(len(new_manager.risks), 2)
            self.assertEqual(new_manager.risks[0].risk_id, "TEST-001")
            self.assertEqual(new_manager.risks[1].risk_id, "TEST-002")
        finally:
            os.unlink(csv_file)


if __name__ == "__main__":
    unittest.main()
```

**Run the Unit Tests:**

```bash
cd 01-governance/scripts
python3 test_risk_calculator.py -v
```

**Expected Output:**
```
test_add_risk (__main__.TestRiskManager) ... ok
test_add_duplicate_risk (__main__.TestRiskManager) ... ok
test_delete_risk (__main__.TestRiskManager) ... ok
test_export_import_csv (__main__.TestRiskManager) ... ok
test_get_risk (__main__.TestRiskManager) ... ok
test_summary_stats (__main__.TestRiskManager) ... ok
test_update_risk (__main__.TestRiskManager) ... ok
test_risk_creation (__main__.TestRisk) ... ok
test_risk_invalid_likelihood (__main__.TestRisk) ... ok
test_risk_levels (__main__.TestRisk) ... ok

----------------------------------------------------------------------
Ran 10 tests in 0.023s

OK
```

### Verification 5: Full Integration Test

**The Implementation:**

Create a script that tests the entire workflow:

**File:** `01-governance/scripts/integration_test.sh`

```bash
#!/bin/bash
# Integration test for the risk management workflow

set -e

echo "=== Risk Management Integration Test ==="
echo

# 1. Test Python environment
echo "1. Testing Python environment..."
python3 --version || { echo "Python3 not found"; exit 1; }
echo "✓ Python3 is available"
echo

# 2. Check risk calculator script
echo "2. Checking risk calculator script..."
if [ -f "risk_calculator.py" ]; then
    echo "✓ risk_calculator.py exists"
else
    echo "✗ risk_calculator.py not found"
    exit 1
fi
echo

# 3. Load risk register
echo "3. Loading risk register..."
python3 risk_calculator.py load ../risk-register/risk-register.csv
echo

# 4. Generate dashboard report
echo "4. Generating dashboard report..."
mkdir -p ../reports
python3 risk_calculator.py dashboard --input ../risk-register/risk-register.csv --output ../reports/test-dashboard.md
echo "✓ Dashboard report generated at ../reports/test-dashboard.md"
echo

# 5. Export to JSON
echo "5. Exporting risk register to JSON..."
python3 risk_calculator.py export --input ../risk-register/risk-register.csv --output ../reports/test-risks.json
echo "✓ JSON exported to ../reports/test-risks.json"
echo

# 6. Run unit tests
echo "6. Running unit tests..."
python3 test_risk_calculator.py
echo "✓ All tests passed"
echo

# 7. Create a new risk with sample data
echo "7. Testing risk addition..."
echo "Creating a new risk..."
python3 -c "
from risk_calculator import Risk, RiskManager
import csv

# Create a new risk
new_risk = Risk(
    risk_id='RISK-2024-011',
    owner='Integration Test',
    description='Integration test risk',
    category='Operational',
    likelihood=2,
    impact=3,
    velocity=2,
    existing_controls='Test controls',
    action_plan='Test plan',
    timeline='Q1 2024',
    status='Open',
    last_review='2024-03-15',
    comments='Created by integration test'
)

# Load existing risks
manager = RiskManager.from_csv('../risk-register/risk-register.csv')

# Add new risk
manager.add_risk(new_risk)
print('✓ Risk added successfully')

# Verify risk count
stats = manager.get_summary_stats()
print(f'  Total risks: {stats[\"total_risks\"]}')
print(f'  Average score: {stats[\"avg_score\"]:.1f}')

# Save back to CSV
manager.to_csv('../risk-register/risk-register-updated.csv')
print('✓ Updated CSV saved')
"

echo
echo "=== Integration Test Complete ==="
echo "✓ All tests passed successfully"
```

**Run the Integration Test:**

```bash
cd 01-governance/scripts
chmod +x integration_test.sh
./integration_test.sh
```

## Key Takeaways

Congratulations! You've completed Part 1 of the Enterprise Cybersecurity Program series. Here's what you've accomplished:

### What You Built

1. **Governance Structure**: Created a comprehensive governance charter with Board-level oversight, executive councils, and operational committees

2. **RACI Matrix**: Defined clear roles and responsibilities using the RACI model, establishing accountability across the organization

3. **Risk Management Framework**: Built a risk-based approach with defined risk appetite, tolerance levels, and a calculation methodology

4. **Risk Calculator Tool**: Created a Python application that automates risk scoring, generates dashboards, and manages the risk register

5. **Security Policies**: Developed foundational policies including Information Security Policy, Access Control Policy, and Acceptable Use Policy

6. **3-Year Strategy**: Created a strategic roadmap with clear milestones, investments, and success metrics

7. **Risk Register**: Implemented a working risk register with 10 sample risks and automated reporting

### Frameworks Implemented

- NIST CSF 2.0 Governance function
- ISO/IEC 27001 ISMS requirements
- CIS Controls for security governance

### Key Decisions You Made

- Risk appetite: Moderate, with specific tolerances
- Risk calculation: Likelihood × Impact × Velocity
- Governance structure: 4-tier oversight
- Strategy horizon: 3 years with annual reviews

### What's Next

In **Part 2**, we'll build on this governance foundation by:
- Discovering and inventorying all enterprise assets
- Implementing data classification
- Designing a Zero Trust Architecture
- Mapping regulatory requirements
- Building a Configuration Management Database (CMDB)

---

**Reference Section: Deep Dive into Risk Management Frameworks**

### A. NIST CSF 2.0 Risk Management

The NIST CSF 2.0 provides a structured approach to risk management through its six core functions:

| Function | Purpose | Key Activities |
|----------|---------|----------------|
| Govern | Establish risk management strategy | Define risk appetite, establish governance |
| Identify | Understand risks | Asset discovery, threat assessment |
| Protect | Implement safeguards | Controls deployment, training |
| Detect | Identify incidents | Monitoring, alerting |
| Respond | Take action | Incident handling, analysis |
| Recover | Restore capabilities | Business continuity, improvements |

### B. ISO/IEC 27001 Risk Requirements

ISO/IEC 27001 Annex A controls map to our risk management framework:

| Control Area | Our Implementation |
|--------------|-------------------|
| A.5: Information security policies | Section 3 (Policies) |
| A.6: Organization of information security | Section 1 (Governance) |
| A.8: Asset management | Part 2 (coming) |
| A.9: Access control | Section 5 (Access Control Policy) |
| A.12: Operations security | Part 3 (coming) |
| A.16: Incident management | Part 4 (coming) |
| A.17: Business continuity | Part 4 (coming) |

### C. Risk Calculation Deep Dive

**Why Likelihood × Impact × Velocity?**

- **Likelihood**: Probability of occurrence
- **Impact**: Business consequence
- **Velocity**: Speed of escalation

This three-dimensional approach provides a more nuanced risk assessment than simple likelihood × impact because it accounts for how quickly a risk can materialize and cause damage.

**Example Scoring:**

| Risk | Likelihood | Impact | Velocity | Score | Level |
|------|------------|--------|----------|-------|-------|
| Phishing email | 5 (frequent) | 3 (moderate) | 4 (fast) | 60 | Critical |
| Solar flare | 1 (rare) | 5 (critical) | 5 (instant) | 25 | Medium |

### D. RACI Best Practices

When creating a RACI matrix, follow these best practices:

1. **One Accountability per Activity**: Only one R (Responsible) per activity
2. **Clear Definitions**: Everyone understands what each letter means
3. **Review with Stakeholders**: Have all roles confirm their assignments
4. **Update Regularly**: Review after organizational changes
5. **Keep It Practical**: Too detailed becomes unmanageable

### E. Further Reading

- NIST CSF 2.0 Framework: https://www.nist.gov/cyberframework
- ISO/IEC 27001:2022 Information Security Management
- FAIR (Factor Analysis of Information Risk) Methodology
- NIST SP 800-30: Guide for Conducting Risk Assessments
