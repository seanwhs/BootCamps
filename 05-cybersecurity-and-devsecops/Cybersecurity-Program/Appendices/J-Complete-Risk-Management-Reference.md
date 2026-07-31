# Appendix J: Complete Risk Management Reference

## Overview

This appendix provides comprehensive risk management reference material for the Enterprise Cybersecurity Program. It includes detailed risk assessment methodologies, risk treatment strategies, risk register templates, and quantitative risk analysis frameworks.

---

## J.1: Risk Assessment Methodologies

### J.1.1: NIST SP 800-30 Risk Assessment Guide

**File:** `risk-management/nist-risk-assessment.md`

```markdown
# NIST SP 800-30 Risk Assessment Methodology

## 1. Risk Assessment Process

### 1.1 Overview

The NIST SP 800-30 risk assessment process consists of four distinct steps:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              RISK ASSESSMENT PROCESS                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                         STEP 1: PREPARE FOR ASSESSMENT                               │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Identify assessment purpose and scope                                        │ │    │
│  │  │  • Identify information and asset types                                        │ │    │
│  │  │  • Define assessment methodology                                               │ │    │
│  │  │  • Identify stakeholder requirements                                           │ │    │
│  │  │  • Assemble assessment team                                                     │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                         STEP 2: CONDUCT ASSESSMENT                                 │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Identify threats                                                            │ │    │
│  │  │  • Identify vulnerabilities                                                    │ │    │
│  │  │  • Determine likelihood                                                         │ │    │
│  │  │  • Determine impact                                                            │ │    │
│  │  │  • Determine risk                                                               │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                         STEP 3: COMMUNICATE RESULTS                                │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Develop risk assessment report                                              │ │    │
│  │  │  • Communicate risk findings                                                   │ │    │
│  │  │  • Identify risk treatment options                                             │ │    │
│  │  │  • Document risk decisions                                                      │ │    │
│  │  │  • Update risk register                                                         │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                         STEP 4: MAINTAIN ASSESSMENT                                │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Monitor risk factors                                                        │ │    │
│  │  │  • Update risk assessment                                                      │ │    │
│  │  │  • Review control effectiveness                                                │ │    │
│  │  │  • Update risk register                                                         │ │    │
│  │  │  • Report changes                                                               │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Step 1: Prepare for Assessment

**1.2.1 Assessment Purpose and Scope**

| Element | Description |
|---------|-------------|
| Assessment Purpose | Why the risk assessment is being conducted |
| Assessment Scope | What systems, assets, and processes are covered |
| Assessment Boundaries | What is included and excluded |
| Assessment Team | Who is performing the assessment |
| Stakeholders | Who needs to be involved or informed |

**1.2.2 Information Collection**

| Information Type | Examples |
|------------------|----------|
| System Documentation | Architecture diagrams, data flows |
| Asset Inventory | Hardware, software, data |
| Vulnerability Information | Scan results, findings |
| Threat Information | Threat intelligence |
| Control Information | Existing controls, policies |

### 1.3 Step 2: Conduct Assessment

**1.3.1 Threat Identification**

| Threat Source | Threat Actions |
|---------------|----------------|
| Adversarial Threat Sources | Malicious actors, insider threats |
| Accidental Threat Sources | Human errors, mistakes |
| Structural Threat Sources | System failures, infrastructure |
| Environmental Threat Sources | Natural disasters, power outages |

**1.3.2 Vulnerability Identification**

| Vulnerability Type | Examples |
|-------------------|----------|
| Technical | Unpatched systems, misconfigurations |
| Operational | Weak procedures, lack of monitoring |
| Administrative | Inadequate policies, insufficient training |
| Physical | Unsecured facilities, weak access controls |

**1.3.3 Likelihood Determination**

| Likelihood Score | Description | Frequency |
|------------------|-------------|-----------|
| 1 - Rare | Highly unlikely | Once in 10+ years |
| 2 - Unlikely | Not expected | Once in 5-10 years |
| 3 - Possible | Could happen | Once in 1-5 years |
| 4 - Likely | Expected | Multiple per year |
| 5 - Almost Certain | Very likely | Frequent (monthly+) |

**1.3.4 Impact Determination**

| Impact Score | Description | Effect |
|--------------|-------------|--------|
| 1 - Minimal | Negligible impact | Minor inconvenience |
| 2 - Minor | Limited impact | Short-term disruption |
| 3 - Moderate | Significant impact | Medium-term disruption |
| 4 - Major | Severe impact | Long-term disruption |
| 5 - Critical | Catastrophic impact | Business threatening |

**1.3.5 Risk Calculation**

Risk = Likelihood × Impact × Velocity

| Score Range | Risk Level | Required Action |
|-------------|------------|-----------------|
| 1-8 | Low | Monitor and document |
| 9-18 | Medium | Mitigate within 90 days |
| 19-36 | High | Mitigate within 30 days |
| 37-125 | Critical | Immediate mitigation |

### 1.4 Step 3: Communicate Results

**1.4.1 Risk Assessment Report**

```markdown
# Risk Assessment Report

## Executive Summary
- Overall risk posture
- Key findings
- Critical risks
- Recommendations

## Risk Assessment Details
- Assessment scope
- Methodology
- Team members
- Timeline

## Findings by Domain
- Technical risks
- Operational risks
- Administrative risks
- Physical risks

## Risk Register Summary
- Risks by severity
- Risk trends
- Risk categories
- Mitigation status

## Recommendations
- Priority improvements
- Resource requirements
- Timeline for completion
- Success metrics
```

### 1.5 Step 4: Maintain Assessment

**1.5.1 Continuous Monitoring**

| Monitoring Activity | Frequency |
|---------------------|-----------|
| Risk register review | Monthly |
| Control effectiveness | Quarterly |
| Threat intelligence updates | Daily |
| Vulnerability scans | Weekly |
| Compliance checks | Monthly |

**1.5.2 Assessment Update Triggers**

- Significant changes to systems or environment
- Major security incidents
- Regulatory changes
- Changes in threat landscape
- Organizational changes
- Control effectiveness changes
```

### J.1.2: FAIR Risk Analysis Methodology

**File:** `risk-management/fair-methodology.md`

```markdown
# FAIR (Factor Analysis of Information Risk) Methodology

## 1. Overview

The FAIR model provides a quantitative approach to measuring and analyzing risk. Unlike qualitative methods, FAIR uses mathematical models to calculate risk in financial terms.

### 1.1 Core Concepts

**Loss Event Frequency (LEF)**
The probable frequency of a loss event within a given timeframe.

**Threat Event Frequency (TEF)**
The probable frequency of a threat agent acting against an asset.

**Vulnerability**
The probability that a threat event will result in a loss event.

**Loss Magnitude (LM)**
The probable magnitude of loss from a loss event.

## 2. FAIR Model

### 2.1 Factor Analysis Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    FAIR RISK MODEL                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              LOSS EVENT FREQUENCY (LEF)                              │    │
│  │  ┌────────────────────────────────────┐  ┌──────────────────────────────────────────┐ │    │
│  │  │   Threat Event Frequency (TEF)     │  │         Vulnerability (V)               │ │    │
│  │  │  ┌──────────────────────────────┐  │  │  ┌────────────────────────────────────┐ │ │    │
│  │  │  │  Threat Agent Capability     │  │  │  │  Control Strength                  │ │ │    │
│  │  │  │  • Skill Level              │  │  │  │  • Technical Controls              │ │ │    │
│  │  │  │  • Resources                │  │  │  │  • Administrative Controls         │ │ │    │
│  │  │  │  • Motivation               │  │  │  │  • Physical Controls               │ │ │    │
│  │  │  └──────────────────────────────┘  │  │  └────────────────────────────────────┘ │ │    │
│  │  │  ┌──────────────────────────────┐  │  │  ┌────────────────────────────────────┐ │ │    │
│  │  │  │  Threat Event Frequency      │  │  │  │  Loss Event Resistance (LER)       │ │ │    │
│  │  │  │  • Frequency of Threat       │  │  │  │  • System Resilience              │ │ │    │
│  │  │  │  • Threat Type               │  │  │  │  • Recovery Capability             │ │ │    │
│  │  │  └──────────────────────────────┘  │  │  └────────────────────────────────────┘ │ │    │
│  │  └────────────────────────────────────┘  │  └──────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              LOSS MAGNITUDE (LM)                                     │    │
│  │  ┌────────────────────────────────────┐  ┌──────────────────────────────────────────┐ │    │
│  │  │  Primary Loss                      │  │  Secondary Loss                          │ │    │
│  │  │  • Productivity Loss              │  │  • Reputation Loss                       │ │    │
│  │  │  • Response Cost                  │  │  • Legal Liability                       │ │    │
│  │  │  • Replacement Cost               │  │  • Regulatory Fines                      │ │    │
│  │  │  • Recovery Cost                  │  │  • Customer Churn                       │ │    │
│  │  └────────────────────────────────────┘  │  • Insurance Premiums                   │ │    │
│  │                                         │  • Stock Price Impact                    │ │    │
│  │                                         └──────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              RISK = LEF × LM                                        │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Quantitative Risk Calculation

```python
#!/usr/bin/env python3
"""
FAIR Risk Calculation Module

This module implements quantitative risk calculations using the FAIR methodology.
"""

import math
import numpy as np
from typing import Dict, List, Tuple

class FAIRCalculator:
    """
    FAIR risk calculation engine.
    """
    
    def __init__(self):
        """Initialize the FAIR calculator."""
        self.factors = {}
    
    def calculate_threat_event_frequency(self, threat_agents: List[Dict]) -> float:
        """
        Calculate Threat Event Frequency (TEF).
        
        Args:
            threat_agents: List of threat agent characteristics
            
        Returns:
            TEF value (events per year)
        """
        total_frequency = 0
        
        for agent in threat_agents:
            # Calculate agent's effective frequency
            capability = agent.get('capability', 0.5)  # 0-1
            motivation = agent.get('motivation', 0.5)  # 0-1
            resources = agent.get('resources', 0.5)    # 0-1
            
            agent_effectiveness = (capability + motivation + resources) / 3
            base_frequency = agent.get('frequency', 1.0)  # Events per year
            
            effective_frequency = base_frequency * agent_effectiveness
            total_frequency += effective_frequency
        
        return total_frequency
    
    def calculate_vulnerability(self, controls: List[Dict]) -> float:
        """
        Calculate Vulnerability (V).
        
        Args:
            controls: List of controls with effectiveness ratings
            
        Returns:
            Vulnerability score (0-1)
        """
        if not controls:
            return 1.0  # No controls = 100% vulnerable
        
        # Calculate control effectiveness
        total_effectiveness = 0
        for control in controls:
            effectiveness = control.get('effectiveness', 0.5)  # 0-1
            importance = control.get('importance', 1.0)       # Relative importance
            
            total_effectiveness += effectiveness * importance
        
        total_importance = sum(c.get('importance', 1.0) for c in controls)
        
        # Vulnerability = 1 - Control_Effectiveness
        control_effectiveness = total_effectiveness / total_importance
        vulnerability = 1.0 - control_effectiveness
        
        return max(0, min(1, vulnerability))  # Clamp between 0 and 1
    
    def calculate_loss_event_frequency(self, threat_event_frequency: float, 
                                      vulnerability: float) -> float:
        """
        Calculate Loss Event Frequency (LEF).
        
        Args:
            threat_event_frequency: TEF value
            vulnerability: V score (0-1)
            
        Returns:
            LEF value (events per year)
        """
        return threat_event_frequency * vulnerability
    
    def calculate_loss_magnitude(self, primary_loss: float, 
                                 secondary_loss: float) -> float:
        """
        Calculate Loss Magnitude (LM).
        
        Args:
            primary_loss: Direct losses
            secondary_loss: Indirect losses
            
        Returns:
            LM value ($)
        """
        return primary_loss + secondary_loss
    
    def calculate_annualized_loss_expectancy(self, loss_event_frequency: float,
                                           loss_magnitude: float) -> float:
        """
        Calculate Annualized Loss Expectancy (ALE).
        
        Args:
            loss_event_frequency: LEF value
            loss_magnitude: LM value
            
        Returns:
            ALE ($/year)
        """
        return loss_event_frequency * loss_magnitude
    
    def calculate_risk(self, scenario: Dict) -> Dict:
        """
        Calculate risk for a scenario.
        
        Args:
            scenario: Risk scenario dictionary
            
        Returns:
            Risk calculation results
        """
        # Extract scenario components
        threat_agents = scenario.get('threat_agents', [])
        controls = scenario.get('controls', [])
        primary_loss_estimate = scenario.get('primary_loss', 100000)
        secondary_loss_estimate = scenario.get('secondary_loss', 50000)
        
        # Calculate factors
        tef = self.calculate_threat_event_frequency(threat_agents)
        v = self.calculate_vulnerability(controls)
        lef = self.calculate_loss_event_frequency(tef, v)
        lm = self.calculate_loss_magnitude(primary_loss_estimate, secondary_loss_estimate)
        ale = self.calculate_annualized_loss_expectancy(lef, lm)
        
        return {
            'threat_event_frequency': tef,
            'vulnerability': v,
            'loss_event_frequency': lef,
            'loss_magnitude': lm,
            'annualized_loss_expectancy': ale,
            'risk_level': self._determine_risk_level(ale)
        }
    
    def _determine_risk_level(self, ale: float) -> str:
        """Determine risk level based on ALE."""
        if ale > 1000000:
            return 'Critical'
        elif ale > 100000:
            return 'High'
        elif ale > 10000:
            return 'Medium'
        else:
            return 'Low'

# Example Usage
def example_fair_calculation():
    """
    Example FAIR risk calculation.
    """
    calculator = FAIRCalculator()
    
    # Define scenario
    scenario = {
        'threat_agents': [
            {
                'capability': 0.8,
                'motivation': 0.7,
                'resources': 0.6,
                'frequency': 5.0  # Attempts per year
            }
        ],
        'controls': [
            {
                'effectiveness': 0.8,
                'importance': 1.0
            },
            {
                'effectiveness': 0.6,
                'importance': 0.8
            }
        ],
        'primary_loss': 500000,   # Direct costs
        'secondary_loss': 100000  # Indirect costs
    }
    
    results = calculator.calculate_risk(scenario)
    
    print("FAIR Risk Assessment Results")
    print("=" * 50)
    print(f"Threat Event Frequency: {results['threat_event_frequency']:.2f}/year")
    print(f"Vulnerability: {results['vulnerability']:.2f}")
    print(f"Loss Event Frequency: {results['loss_event_frequency']:.2f}/year")
    print(f"Loss Magnitude: ${results['loss_magnitude']:,.0f}")
    print(f"Annualized Loss Expectancy: ${results['annualized_loss_expectancy']:,.0f}")
    print(f"Risk Level: {results['risk_level']}")

if __name__ == "__main__":
    example_fair_calculation()
```

---

## J.2: Risk Register Management

### J.2.1: Risk Register Template

**File:** `risk-management/risk-register-template.csv`

```csv
Risk ID,Risk Title,Description,Category,Source,Owner,Status,Likelihood,Impact,Velocity,Risk Score,Risk Level,Controls,Action Plan,Timeline,Residual Risk,Created Date,Updated Date,Review Date
RISK-2024-001,Unauthorized Access to PII,"Risk of unauthorized access to customer PII due to insufficient access controls",Data Security,Internal Audit,John Smith,Open,3,4,3,36,High,"MFA, RBAC, Access logs","Implement DLP, Data masking, Anomaly detection",Q3 2024,18,2024-01-15,2024-03-15,2024-06-15
RISK-2024-002,Ransomware Impact,"Risk of ransomware impacting critical systems",Operational,Threat Intel,Jane Doe,In Progress,4,5,4,80,Critical,"EDR, Backups, Network segmentation","Air-gapped backups, EDR upgrade, Recovery testing",Q2 2024,25,2024-01-15,2024-03-15,2024-04-15
RISK-2024-003,Supply Chain Vulnerability,"Risk of software supply chain compromise",Third-Party,External,Bob Smith,Open,3,3,3,27,Medium,"SBOM scanning, Vendor assessments","Supply chain security program, Continuous monitoring",Q4 2024,15,2024-01-15,2024-03-15,2024-09-15
RISK-2024-004,GDPR Non-Compliance,"Risk of GDPR non-compliance in EU operations",Compliance,Regulatory,Sarah Johnson,In Progress,2,5,2,20,High,"Data classification, Privacy notices","GDPR controls implementation, DPO review",Q3 2024,12,2024-01-15,2024-03-15,2024-06-15
RISK-2024-005,Insider Data Exfiltration,"Risk of insider data exfiltration",Data Security,Internal,John Smith,Open,2,4,2,16,Medium,"DLP, Access controls, Monitoring","UEBA deployment, Enhanced DLP",Q2 2024,10,2024-01-15,2024-03-15,2024-04-15
RISK-2024-006,Cloud Misconfiguration,"Risk of cloud security misconfiguration",Operational,External,Jane Doe,In Progress,4,3,4,48,High,"Cloud security tools, IAM","CSPM implementation, Configuration reviews",Q2 2024,24,2024-01-15,2024-03-15,2024-04-15
RISK-2024-007,Critical Data Loss,"Risk of loss of critical data",Operational,Internal,Bob Smith,Open,2,5,3,30,High,"Backups, Replication","Immutable backups, DR testing",Q3 2024,15,2024-01-15,2024-03-15,2024-06-15
RISK-2024-008,DSAR Handling,"Risk of data subject access request handling issues",Compliance,Regulatory,Sarah Johnson,Open,3,3,2,18,Medium,"DSAR process, Documentation","Automated DSAR platform, Training",Q4 2024,12,2024-01-15,2024-03-15,2024-09-15
RISK-2024-009,Patch Management,"Risk of inadequate patch management",Operational,Internal,John Smith,In Progress,4,2,3,24,High,"Patch management policy, Automation","Automated patching, Vulnerability scanning",Q3 2024,15,2024-01-15,2024-03-15,2024-06-15
RISK-2024-010,Vendor Access Abuse,"Risk of vendor access abuse",Third-Party,Internal,Jane Doe,Open,2,3,2,12,Medium,"Vendor access reviews, MFA","Continuous monitoring, Access audits",Q4 2024,8,2024-01-15,2024-03-15,2024-09-15
```

### J.2.2: Risk Register Management Script

**File:** `risk-management/risk_register_manager.py`

```python
#!/usr/bin/env python3
"""
Risk Register Management Module

This module provides comprehensive risk register management functionality.
"""

import json
import csv
import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from enum import Enum
import os


class RiskLevel(Enum):
    """Risk level categories."""
    CRITICAL = "Critical"
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"


class RiskStatus(Enum):
    """Risk status values."""
    OPEN = "Open"
    IN_PROGRESS = "In Progress"
    MITIGATED = "Mitigated"
    ACCEPTED = "Accepted"
    AVOIDED = "Avoided"
    TRANSFERRED = "Transferred"


class RiskCategory(Enum):
    """Risk category values."""
    DATA_SECURITY = "Data Security"
    OPERATIONAL = "Operational"
    THIRD_PARTY = "Third-Party"
    COMPLIANCE = "Compliance"
    GOVERNANCE = "Governance"
    PHYSICAL = "Physical"
    FINANCIAL = "Financial"
    REPUTATIONAL = "Reputational"


@dataclass
class Risk:
    """Risk data class."""
    risk_id: str
    title: str
    description: str
    category: str
    source: str
    owner: str
    status: str
    likelihood: int
    impact: int
    velocity: int
    risk_score: int
    risk_level: str
    controls: str
    action_plan: str
    timeline: str
    residual_risk: int
    created_date: str
    updated_date: str
    review_date: str
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            'risk_id': self.risk_id,
            'title': self.title,
            'description': self.description,
            'category': self.category,
            'source': self.source,
            'owner': self.owner,
            'status': self.status,
            'likelihood': self.likelihood,
            'impact': self.impact,
            'velocity': self.velocity,
            'risk_score': self.risk_score,
            'risk_level': self.risk_level,
            'controls': self.controls,
            'action_plan': self.action_plan,
            'timeline': self.timeline,
            'residual_risk': self.residual_risk,
            'created_date': self.created_date,
            'updated_date': self.updated_date,
            'review_date': self.review_date
        }


class RiskRegisterManager:
    """
    Risk Register Manager.
    
    This class handles risk register CRUD operations, reporting,
    and analytics.
    """
    
    def __init__(self, data_dir: str = "./risk_data"):
        """
        Initialize the risk register manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        self.risks: List[Risk] = []
        self._load_data()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
    
    def _load_data(self) -> None:
        """Load risks from persistent storage."""
        risk_file = f"{self.data_dir}/risks.json"
        if os.path.exists(risk_file):
            with open(risk_file, 'r') as f:
                data = json.load(f)
                for risk_data in data:
                    risk = Risk(
                        risk_id=risk_data['risk_id'],
                        title=risk_data['title'],
                        description=risk_data['description'],
                        category=risk_data['category'],
                        source=risk_data['source'],
                        owner=risk_data['owner'],
                        status=risk_data['status'],
                        likelihood=risk_data['likelihood'],
                        impact=risk_data['impact'],
                        velocity=risk_data['velocity'],
                        risk_score=risk_data['risk_score'],
                        risk_level=risk_data['risk_level'],
                        controls=risk_data['controls'],
                        action_plan=risk_data['action_plan'],
                        timeline=risk_data['timeline'],
                        residual_risk=risk_data['residual_risk'],
                        created_date=risk_data['created_date'],
                        updated_date=risk_data['updated_date'],
                        review_date=risk_data['review_date']
                    )
                    self.risks.append(risk)
    
    def _save_data(self) -> None:
        """Save risks to persistent storage."""
        risk_file = f"{self.data_dir}/risks.json"
        data = [risk.to_dict() for risk in self.risks]
        with open(risk_file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def calculate_risk_score(self, likelihood: int, impact: int, 
                            velocity: int) -> int:
        """
        Calculate risk score.
        
        Args:
            likelihood: Likelihood score (1-5)
            impact: Impact score (1-5)
            velocity: Velocity score (1-5)
            
        Returns:
            Risk score (1-125)
        """
        return likelihood * impact * velocity
    
    def determine_risk_level(self, risk_score: int) -> str:
        """
        Determine risk level from risk score.
        
        Args:
            risk_score: Risk score (1-125)
            
        Returns:
            Risk level string
        """
        if risk_score >= 60:
            return RiskLevel.CRITICAL.value
        elif risk_score >= 30:
            return RiskLevel.HIGH.value
        elif risk_score >= 10:
            return RiskLevel.MEDIUM.value
        else:
            return RiskLevel.LOW.value
    
    def add_risk(self, risk_data: Dict) -> Risk:
        """
        Add a new risk.
        
        Args:
            risk_data: Risk data dictionary
            
        Returns:
            Created Risk object
        """
        # Calculate risk score if not provided
        if 'risk_score' not in risk_data:
            risk_data['risk_score'] = self.calculate_risk_score(
                risk_data['likelihood'],
                risk_data['impact'],
                risk_data['velocity']
            )
        
        # Determine risk level if not provided
        if 'risk_level' not in risk_data:
            risk_data['risk_level'] = self.determine_risk_level(
                risk_data['risk_score']
            )
        
        # Set timestamps
        now = datetime.datetime.utcnow().isoformat()
        risk_data['created_date'] = now
        risk_data['updated_date'] = now
        
        # Create risk
        risk = Risk(**risk_data)
        
        # Add to list
        self.risks.append(risk)
        self._save_data()
        
        return risk
    
    def update_risk(self, risk_id: str, updates: Dict) -> Optional[Risk]:
        """
        Update an existing risk.
        
        Args:
            risk_id: Risk ID to update
            updates: Fields to update
            
        Returns:
            Updated Risk or None if not found
        """
        for risk in self.risks:
            if risk.risk_id == risk_id:
                # Update fields
                for key, value in updates.items():
                    if hasattr(risk, key):
                        setattr(risk, key, value)
                
                # Update risk score if components changed
                if any(k in updates for k in ['likelihood', 'impact', 'velocity']):
                    risk.risk_score = self.calculate_risk_score(
                        risk.likelihood,
                        risk.impact,
                        risk.velocity
                    )
                    risk.risk_level = self.determine_risk_level(risk.risk_score)
                
                # Update timestamp
                risk.updated_date = datetime.datetime.utcnow().isoformat()
                
                self._save_data()
                return risk
        
        return None
    
    def delete_risk(self, risk_id: str) -> bool:
        """
        Delete a risk.
        
        Args:
            risk_id: Risk ID to delete
            
        Returns:
            True if deleted, False if not found
        """
        for i, risk in enumerate(self.risks):
            if risk.risk_id == risk_id:
                del self.risks[i]
                self._save_data()
                return True
        return False
    
    def get_risk(self, risk_id: str) -> Optional[Risk]:
        """
        Get a risk by ID.
        
        Args:
            risk_id: Risk ID
            
        Returns:
            Risk or None if not found
        """
        for risk in self.risks:
            if risk.risk_id == risk_id:
                return risk
        return None
    
    def get_risks_by_level(self, level: str) -> List[Risk]:
        """
        Get risks by risk level.
        
        Args:
            level: Risk level (Critical, High, Medium, Low)
            
        Returns:
            List of risks at that level
        """
        return [r for r in self.risks if r.risk_level == level]
    
    def get_risks_by_status(self, status: str) -> List[Risk]:
        """
        Get risks by status.
        
        Args:
            status: Risk status
            
        Returns:
            List of risks with that status
        """
        return [r for r in self.risks if r.status == status]
    
    def get_summary_stats(self) -> Dict:
        """
        Get summary statistics.
        
        Returns:
            Dictionary of statistics
        """
        if not self.risks:
            return {
                'total': 0,
                'by_level': {},
                'by_status': {},
                'by_category': {},
                'avg_score': 0,
                'open_critical': 0
            }
        
        stats = {
            'total': len(self.risks),
            'by_level': {level.value: 0 for level in RiskLevel},
            'by_status': {status.value: 0 for status in RiskStatus},
            'by_category': {category.value: 0 for category in RiskCategory},
            'scores': [],
            'open_critical': 0
        }
        
        for risk in self.risks:
            stats['by_level'][risk.risk_level] = stats['by_level'].get(risk.risk_level, 0) + 1
            stats['by_status'][risk.status] = stats['by_status'].get(risk.status, 0) + 1
            stats['by_category'][risk.category] = stats['by_category'].get(risk.category, 0) + 1
            stats['scores'].append(risk.risk_score)
            
            if risk.status == 'Open' and risk.risk_level == 'Critical':
                stats['open_critical'] += 1
        
        stats['avg_score'] = sum(stats['scores']) / len(stats['scores']) if stats['scores'] else 0
        
        return stats
    
    def generate_report(self) -> str:
        """
        Generate markdown risk report.
        
        Returns:
            Markdown formatted report
        """
        stats = self.get_summary_stats()
        
        report = f"""
# Risk Register Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Risks | {stats['total']} |
| Open Critical Risks | {stats['open_critical']} |
| Average Risk Score | {stats['avg_score']:.1f} |

## Risk Distribution

### By Level

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
        
        report += """
## Top 5 High-Risk Items

| ID | Title | Owner | Score | Level | Status |
|----|-------|-------|-------|-------|--------|
"""
        
        sorted_risks = sorted(self.risks, key=lambda r: r.risk_score, reverse=True)
        for risk in sorted_risks[:5]:
            report += f"| {risk.risk_id} | {risk.title[:30]}... | {risk.owner} | {risk.risk_score} | {risk.risk_level} | {risk.status} |\n"
        
        return report
    
    def export_to_csv(self, filename: str) -> None:
        """
        Export risk register to CSV.
        
        Args:
            filename: Output CSV file path
        """
        with open(filename, 'w', newline='') as csvfile:
            fieldnames = [
                'risk_id', 'title', 'description', 'category', 'source',
                'owner', 'status', 'likelihood', 'impact', 'velocity',
                'risk_score', 'risk_level', 'controls', 'action_plan',
                'timeline', 'residual_risk', 'created_date', 'updated_date',
                'review_date'
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            for risk in self.risks:
                writer.writerow(risk.to_dict())
    
    def import_from_csv(self, filename: str) -> int:
        """
        Import risks from CSV.
        
        Args:
            filename: CSV file path
            
        Returns:
            Number of risks imported
        """
        count = 0
        with open(filename, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # Convert numeric fields
                for field in ['likelihood', 'impact', 'velocity', 'risk_score', 'residual_risk']:
                    if field in row and row[field]:
                        row[field] = int(row[field])
                
                risk = Risk(**row)
                self.risks.append(risk)
                count += 1
        
        self._save_data()
        return count


def main():
    """CLI for risk register management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Risk Register Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Add risk
    add_parser = subparsers.add_parser('add', help='Add risk')
    add_parser.add_argument('--interactive', '-i', action='store_true', help='Interactive mode')
    
    # List risks
    list_parser = subparsers.add_parser('list', help='List risks')
    list_parser.add_argument('--level', '-l', help='Filter by risk level')
    list_parser.add_argument('--status', '-s', help='Filter by status')
    
    # Update risk
    update_parser = subparsers.add_parser('update', help='Update risk')
    update_parser.add_argument('--id', '-i', required=True, help='Risk ID')
    update_parser.add_argument('--fields', '-f', required=True, help='Fields to update (JSON)')
    
    # Delete risk
    delete_parser = subparsers.add_parser('delete', help='Delete risk')
    delete_parser.add_argument('--id', '-i', required=True, help='Risk ID')
    
    # Generate report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    # Export
    export_parser = subparsers.add_parser('export', help='Export to CSV')
    export_parser.add_argument('--output', '-o', default='risk_register.csv', help='Output file')
    
    # Import
    import_parser = subparsers.add_parser('import', help='Import from CSV')
    import_parser.add_argument('--input', '-i', required=True, help='Input CSV file')
    
    args = parser.parse_args()
    
    manager = RiskRegisterManager()
    
    if args.command == 'add':
        if args.interactive:
            print("=== Add New Risk ===")
            risk_data = {}
            risk_data['risk_id'] = input("Risk ID: ")
            risk_data['title'] = input("Title: ")
            risk_data['description'] = input("Description: ")
            risk_data['category'] = input("Category: ")
            risk_data['source'] = input("Source: ")
            risk_data['owner'] = input("Owner: ")
            risk_data['status'] = input("Status: ")
            risk_data['likelihood'] = int(input("Likelihood (1-5): "))
            risk_data['impact'] = int(input("Impact (1-5): "))
            risk_data['velocity'] = int(input("Velocity (1-5): "))
            risk_data['controls'] = input("Controls: ")
            risk_data['action_plan'] = input("Action Plan: ")
            risk_data['timeline'] = input("Timeline: ")
            risk_data['residual_risk'] = int(input("Residual Risk: "))
            risk_data['review_date'] = input("Review Date (YYYY-MM-DD): ")
            
            risk = manager.add_risk(risk_data)
            print(f"✅ Risk added: {risk.risk_id}")
            print(f"   Risk Score: {risk.risk_score}")
            print(f"   Risk Level: {risk.risk_level}")
        else:
            print("Use --interactive for interactive add")
    
    elif args.command == 'list':
        risks = manager.risks
        if args.level:
            risks = [r for r in risks if r.risk_level == args.level]
        if args.status:
            risks = [r for r in risks if r.status == args.status]
        
        print("\nRisks:")
        print("=" * 80)
        for risk in risks:
            status_icon = {
                'Open': '🔴',
                'In Progress': '🟡',
                'Mitigated': '🟢',
                'Accepted': '🔵',
                'Avoided': '⚪',
                'Transferred': '🟣'
            }.get(risk.status, '⚪')
            
            print(f"{status_icon} {risk.risk_id}: {risk.title}")
            print(f"   Level: {risk.risk_level} | Score: {risk.risk_score}")
            print(f"   Owner: {risk.owner} | Status: {risk.status}")
    
    elif args.command == 'update':
        try:
            updates = json.loads(args.fields)
            risk = manager.update_risk(args.id, updates)
            if risk:
                print(f"✅ Risk updated: {risk.risk_id}")
                print(f"   New Score: {risk.risk_score}")
                print(f"   New Level: {risk.risk_level}")
            else:
                print("❌ Risk not found")
        except json.JSONDecodeError:
            print("❌ Invalid JSON")
    
    elif args.command == 'delete':
        if manager.delete_risk(args.id):
            print(f"✅ Risk deleted: {args.id}")
        else:
            print("❌ Risk not found")
    
    elif args.command == 'report':
        report = manager.generate_report()
        print(report)
    
    elif args.command == 'export':
        manager.export_to_csv(args.output)
        print(f"✅ Risk register exported to {args.output}")
    
    elif args.command == 'import':
        count = manager.import_from_csv(args.input)
        print(f"✅ Imported {count} risks from {args.input}")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

---

## J.3: Risk Treatment Strategies

### J.3.1: Risk Treatment Decision Framework

**File:** `risk-management/risk-treatment.md`

```markdown
# Risk Treatment Decision Framework

## 1. Risk Treatment Options

### 1.1 Risk Avoidance

**Definition:** Eliminating the risk by choosing not to perform the activity.

**When to Use:**
- Risk exceeds risk appetite
- Cost of mitigation exceeds benefit
- Unable to effectively mitigate
- Not core to business

**Examples:**
- Discontinuing a product line
- Avoiding new market entry
- Eliminating risky functionality
- Not using a high-risk vendor

**Decision Factors:**
- Business impact of avoidance
- Opportunity cost
- Strategic alignment
- Regulatory requirements

### 1.2 Risk Reduction

**Definition:** Implementing controls to reduce the likelihood or impact of risk.

**When to Use:**
- Risk can be effectively mitigated
- Mitigation cost is reasonable
- Risk is within tolerance after mitigation
- Operational requirement exists

**Examples:**
- Implementing MFA
- Deploying firewalls
- Conducting security training
- Enhancing monitoring

**Decision Factors:**
- Control effectiveness
- Cost of controls
- Operational impact
- Implementation timeline

### 1.3 Risk Transfer

**Definition:** Shifting the risk to a third party (insurance, outsourcing).

**When to Use:**
- Risk cannot be effectively controlled
- Third party has better capability
- Insurance coverage is available
- Cost-effective alternative

**Examples:**
- Cyber insurance
- Outsourcing to managed security provider
- Cloud service provider responsibility
- Vendor contracts

**Decision Factors:**
- Transfer cost
- Provider capability
- Residual liability
- Regulatory requirements

### 1.4 Risk Acceptance

**Definition:** Acknowledging the risk and taking no action.

**When to Use:**
- Risk is within appetite
- Mitigation cost exceeds benefit
- Residual risk is acceptable
- Business necessity

**Examples:**
- Accepting minor risks
- Accepting risks with low impact
- Accepting risks with low likelihood
- Accepting risks with high mitigation cost

**Decision Factors:**
- Risk appetite
- Business priority
- Cost-benefit analysis
- Regulatory requirements

## 2. Risk Treatment Decision Matrix

### 2.1 Decision Criteria

| Criteria | Weight | Description |
|----------|--------|-------------|
| Risk Level | 25% | Criticality of the risk |
| Business Impact | 20% | Impact on business operations |
| Control Effectiveness | 15% | Effectiveness of available controls |
| Implementation Cost | 15% | Cost to implement controls |
| Implementation Timeline | 10% | Time to implement controls |
| Regulatory Requirement | 10% | Regulatory compliance impact |
| Resource Availability | 5% | Availability of resources |

### 2.2 Decision Matrix

| Risk Level | Control Cost | Impact | Recommended Action |
|------------|--------------|--------|-------------------|
| Critical | Low | High | Reduction (Immediate) |
| Critical | Medium | High | Reduction (Urgent) |
| Critical | High | High | Transfer (Insurance) |
| Critical | High | Medium | Avoidance |
| High | Low | High | Reduction |
| High | Medium | Medium | Reduction/Transfer |
| High | High | Low | Acceptance/Transfer |
| Medium | Low | Medium | Reduction |
| Medium | Medium | Low | Acceptance |
| Medium | High | Low | Acceptance |
| Low | Any | Any | Acceptance/Monitor |

## 3. Risk Treatment Planning

### 3.1 Treatment Plan Template

```yaml
Risk Treatment Plan:
  risk_id: [Risk ID]
  risk_title: [Risk Title]
  
  treatment_selection:
    - primary_strategy: [Avoid/Reduce/Transfer/Accept]
      justification: [Why this strategy was chosen]
      alternatives_considered:
        - [Alternative 1]
        - [Alternative 2]
  
  controls:
    - control_name: [Control Name]
      type: [Technical/Administrative/Physical]
      implementation_priority: [Critical/High/Medium/Low]
      effectiveness_rating: [0-1]
      implementation_plan:
        - step: [Step description]
          owner: [Responsible person]
          timeline: [Timeline]
      validation:
        - method: [Testing/Audit/Review]
          frequency: [Frequency]
  
  timeline:
    - phase: [Phase]
      duration: [Timeframe]
      milestones:
        - milestone: [Milestone]
          date: [Date]
  
  budget:
    - category: [Category]
      amount: [Amount]
      source: [Source]
  
  measurement:
    - metric: [Metric]
      target: [Target]
      frequency: [Frequency]
  
  residual_risk:
    level: [After treatment]
    acceptance: [Approved/Need Approval]
    approval: [Name/Date]
```

### 3.2 Control Selection Criteria

**Effectiveness Assessment:**

| Control Type | Effectiveness | Implementation Cost | Operational Impact |
|--------------|---------------|---------------------|-------------------|
| Technical | High | Medium-High | Low-Medium |
| Administrative | Medium | Low-Medium | Medium |
| Physical | High | High | Low |
| Combined | Very High | High | Medium |

**Control Selection Matrix:**

| Risk Level | Recommended Control | Priority |
|------------|--------------------|----------|
| Critical | Combined (Tech + Admin + Physical) | 1 |
| High | Technical + Administrative | 2 |
| Medium | Technical or Administrative | 3 |
| Low | Administrative (Policy) | 4 |

## 4. Risk Monitoring

### 4.1 Monitoring Requirements

| Monitoring Type | Frequency | Responsibility |
|-----------------|-----------|----------------|
| Risk Register Review | Monthly | Risk Owner |
| Control Effectiveness | Quarterly | Control Owner |
| Risk Reassessment | Annual | Risk Owner |
| Regulatory Changes | As needed | Compliance |
| Threat Landscape | Continuous | Security Team |

### 4.2 Review Process

1. **Monthly Review**
   - Review risk status
   - Update risk register
   - Report changes
   - Track mitigation progress

2. **Quarterly Review**
   - Validate control effectiveness
   - Reassess risk likelihood and impact
   - Update risk treatment plan
   - Report to stakeholders

3. **Annual Review**
   - Full risk reassessment
   - Update risk register
   - Review risk appetite
   - Update risk framework
   - Report to executive leadership
```

---

This concludes Appendix J: Complete Risk Management Reference. This comprehensive reference provides the risk assessment methodologies, risk register management, and risk treatment frameworks needed to implement a mature risk management program for the Enterprise Cybersecurity Program.
