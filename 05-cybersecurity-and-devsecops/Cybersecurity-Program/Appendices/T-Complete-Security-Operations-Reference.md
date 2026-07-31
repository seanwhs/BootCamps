# Appendix T: Complete Security Operations Reference

## Overview

This appendix provides comprehensive security operations reference material for the Enterprise Cybersecurity Program. It includes SOC procedures, runbooks, shift schedules, and operational metrics.

---

## T.1: Security Operations Center (SOC) Framework

### T.1.1: SOC Structure and Roles

**File:** `security-operations/soc-structure.md`

```markdown
# Security Operations Center (SOC) Structure

## 1. SOC Overview

### 1.1 SOC Mission
To protect the organization through continuous monitoring, detection, and response to security threats.

### 1.2 SOC Objectives
1. Detect threats early
2. Respond quickly and effectively
3. Minimize business impact
4. Improve security posture
5. Enable business operations

## 2. SOC Organization

### 2.1 SOC Structure

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     SOC ORGANIZATION                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                    SOC MANAGEMENT                                    │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  SOC Manager  │  Deputy SOC Manager  │  Shift Supervisors  │                    │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                    SOC TEAMS                                         │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  Tier 1 Analysts  │  Tier 2 Analysts  │  Tier 3 Analysts  │  Threat Hunters     │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                    SPECIALISTS                                      │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  Incident Responders  │  Forensic Analysts  │  Threat Intel Analysts           │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                    SUPPORT ROLES                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  SOC Engineers  │  Security Architects  │  Data Analysts  │                    │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Role Definitions

**SOC Manager:**
- **Responsibilities:** Overall SOC operations, strategic planning, budget management
- **Skills:** Leadership, strategic planning, incident management
- **Experience:** 8+ years security, 3+ years management
- **Reports to:** CISO

**Shift Supervisor:**
- **Responsibilities:** Team management, escalation handling, shift coordination
- **Skills:** Leadership, incident response, communication
- **Experience:** 5+ years security, 2+ years team lead
- **Reports to:** SOC Manager

**Tier 1 Analyst:**
- **Responsibilities:** Alert triage, initial investigation, documentation
- **Skills:** Alert handling, communication, documentation
- **Experience:** 1-3 years security, Security+ preferred
- **Reports to:** Shift Supervisor

**Tier 2 Analyst:**
- **Responsibilities:** Deep investigation, analysis, incident coordination
- **Skills:** Investigation, analysis, incident response
- **Experience:** 3-5 years security, GCIH preferred
- **Reports to:** Shift Supervisor

**Tier 3 Analyst:**
- **Responsibilities:** Advanced investigation, threat hunting, mentoring
- **Skills:** Advanced analysis, threat hunting, mentoring
- **Experience:** 5+ years security, CISSP/GCIH preferred
- **Reports to:** SOC Manager

**Threat Hunter:**
- **Responsibilities:** Proactive threat hunting, advanced detection
- **Skills:** Threat hunting, advanced analytics, research
- **Experience:** 5+ years security, CTIA preferred
- **Reports to:** SOC Manager

**Incident Responder:**
- **Responsibilities:** Incident response execution, containment, recovery
- **Skills:** Incident response, forensics, communication
- **Experience:** 5+ years security, GCIH/GCIA preferred
- **Reports to:** SOC Manager

**Forensic Analyst:**
- **Responsibilities:** Digital forensics, evidence collection, analysis
- **Skills:** Forensics, evidence handling, analysis
- **Experience:** 5+ years security, GCFE/CFCE preferred
- **Reports to:** SOC Manager

**Threat Intelligence Analyst:**
- **Responsibilities:** Threat intelligence collection, analysis, dissemination
- **Skills:** Threat intelligence, research, analysis
- **Experience:** 3-5 years security, CTIA preferred
- **Reports to:** SOC Manager

## 3. SOC Tiers

### 3.1 Tier 1: Triage and Initial Investigation

| Capability | Description | Tools | Skills |
|------------|-------------|-------|--------|
| Alert Triage | Review and prioritize alerts | SIEM, EDR | Pattern recognition |
| Initial Investigation | Gather context, verify alerts | SIEM, EDR | Analytical thinking |
| Escalation | Escalate to Tier 2 as needed | Ticketing system | Judgment |
| Documentation | Document all actions | Ticketing system | Attention to detail |

**Tier 1 Workflow:**
1. Alert received
2. Review alert details
3. Gather initial context
4. Perform initial investigation
5. Determine if actionable
6. Escalate or resolve
7. Document all actions

### 3.2 Tier 2: Investigation and Analysis

| Capability | Description | Tools | Skills |
|------------|-------------|-------|--------|
| Deep Investigation | Thorough investigation of alerts | SIEM, EDR, Threat Intel | Analytical thinking |
| Incident Handling | Manage incidents through lifecycle | Ticketing system | Incident response |
| Correlation | Correlate multiple events | SIEM | Pattern recognition |
| Incident Reporting | Document and report findings | Reporting tools | Technical writing |

**Tier 2 Workflow:**
1. Escalated alert received
2. Conduct deep investigation
3. Correlate with other events
4. Determine incident severity
5. Manage incident lifecycle
6. Document all actions
7. Report findings

### 3.3 Tier 3: Advanced Investigation and Threat Hunting

| Capability | Description | Tools | Skills |
|------------|-------------|-------|--------|
| Advanced Investigation | Complex investigation | SIEM, EDR, Threat Intel | Deep technical knowledge |
| Threat Hunting | Proactive threat hunting | SIEM, EDR, Threat Intel | Research skills |
| Root Cause Analysis | Identify root cause | All tools | Analytical thinking |
| Mentoring | Mentor Tier 1/2 analysts | N/A | Teaching skills |

**Tier 3 Workflow:**
1. Complex investigation received
2. Conduct advanced analysis
3. Perform threat hunting
4. Identify root cause
5. Provide recommendations
6. Mentor other analysts
7. Document findings

## 4. SOC Shifts

### 4.1 Shift Schedule

| Shift | Time | Team Size | Responsibilities |
|-------|------|-----------|------------------|
| Day | 6:00 AM - 2:00 PM | 8-10 | Full operations |
| Afternoon | 2:00 PM - 10:00 PM | 6-8 | Full operations |
| Night | 10:00 PM - 6:00 AM | 4-6 | Critical monitoring |

### 4.2 Shift Coverage Requirements

| Requirement | Day | Afternoon | Night |
|-------------|-----|-----------|-------|
| Shift Supervisor | Yes | Yes | Yes |
| Tier 1 Analysts | 4-6 | 3-4 | 2-3 |
| Tier 2 Analysts | 2-3 | 2-3 | 1-2 |
| Tier 3 Analysts | 1-2 | 1-2 | 1 |
| On-Call Support | Yes | Yes | Yes |

## 5. SOC Facilities

### 5.1 Physical Requirements

| Requirement | Standard | Notes |
|-------------|----------|-------|
| Location | Secure facility | No windows, controlled access |
| Size | 500 sq ft min | 2 analysts per 100 sq ft |
| Security | Multi-factor access | Biometric + card |
| Power | UPS + Generator | 100% uptime |
| Climate | Temperature controlled | 68-72°F |
| Noise | Soundproofing | Minimize distractions |

### 5.2 Technical Requirements

| Requirement | Standard | Notes |
|-------------|----------|-------|
| Workstations | Dual monitors min | 4K displays recommended |
| Network | Redundant connections | 1Gbps min |
| Phones | Dedicated lines | Direct numbers |
| Communication | Redundant systems | VoIP, cellular backup |
| Video | Conference capability | 4K video |
| Displays | Large monitors | SOC wall displays |
```

### T.1.2: SOC Operations Manual

**File:** `security-operations/soc-operations.md`

```markdown
# SOC Operations Manual

## 1. Shift Operations

### 1.1 Shift Handover Process

**Handover Checklist:**
- [ ] Review active incidents
- [ ] Review pending alerts
- [ ] Review system health
- [ ] Review maintenance activities
- [ ] Review threat intelligence
- [ ] Review outstanding tickets
- [ ] Document key activities
- [ ] Provide handover briefing

**Handover Template:**

```yaml
# SOC Shift Handover
shift:
  date: [Date]
  time: [Time]
  from_team: [Team]
  to_team: [Team]

active_incidents:
  - id: [ID]
    status: [Status]
    summary: [Summary]
    owner: [Owner]
    next_steps: [Steps]

pending_alerts:
  - id: [ID]
    severity: [Severity]
    summary: [Summary]
    action: [Action]

system_health:
  - system: [System]
    status: [Status]
    issues: [Issues]

maintenance_activities:
  - activity: [Activity]
    status: [Status]
    impact: [Impact]

threat_intelligence:
  - update: [Update]
    impact: [Impact]

notable_events:
  - event: [Event]
    details: [Details]
    actions: [Actions]

handover_notes:
  - note: [Note]
```

### 1.2 Daily Operations

**Shift Routine:**

```yaml
# Daily Operations Schedule
routine:
  - time: "6:00 AM"
    activity: "System health checks"
    duration: "30 minutes"
    
  - time: "6:30 AM"
    activity: "Alert review"
    duration: "30 minutes"
    
  - time: "7:00 AM"
    activity: "Incident triage"
    duration: "60 minutes"
    
  - time: "8:00 AM"
    activity: "Team briefing"
    duration: "15 minutes"
    
  - time: "8:15 AM"
    activity: "Operations"
    duration: "Varies"
    
  - time: "12:00 PM"
    activity: "Mid-shift checks"
    duration: "15 minutes"
    
  - time: "1:45 PM"
    activity: "Shift handover preparation"
    duration: "15 minutes"
    
  - time: "2:00 PM"
    activity: "Shift handover"
    duration: "15 minutes"
```

## 2. Incident Triage Process

### 2.1 Triage Workflow

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     INCIDENT TRIAGE                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  1. Alert Received                                                                          │
│     ├── Check alert source                                                                 │
│     ├── Review alert details                                                                │
│     └── Note initial severity                                                               │
│                                                                                             │
│  2. Initial Review (5 minutes)                                                              │
│     ├── Check for false positives                                                           │
│     ├── Review impacted assets                                                              │
│     ├── Determine business impact                                                           │
│     └── Identify potential cause                                                            │
│                                                                                             │
│  3. Classification (5 minutes)                                                              │
│     ├── Assign severity level                                                               │
│     ├── Determine incident type                                                             │
│     ├── Identify affected systems                                                           │
│     └── Note potential impact                                                               │
│                                                                                             │
│  4. Investigation (15 minutes)                                                              │
│     ├── Gather additional context                                                           │
│     ├── Review logs                                                                        │
│     ├── Check threat intelligence                                                           │
│     └── Verify alert                                                                       │
│                                                                                             │
│  5. Resolution/ Escalation (5 minutes)                                                      │
│     ├── If resolved: Document and close                                                    │
│     └── If not resolved: Escalate                                                           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Severity Classification

| Severity | Criteria | Response Time | Escalation |
|----------|----------|---------------|------------|
| Critical | - Business impact<br>- Data breach<br>- Active threat | Immediate | CISO, Executive |
| High | - Significant impact<br>- Potential breach<br>- Contained threat | <15 minutes | SOC Manager |
| Medium | - Limited impact<br>- No breach<br>- Easily contained | <30 minutes | Shift Supervisor |
| Low | - Minimal impact<br>- No breach<br>- Informational | <1 hour | Tier 1 Analyst |

## 3. Monitoring Procedures

### 3.1 Monitoring Priorities

| Priority | Assets | Monitoring | Frequency |
|----------|--------|------------|-----------|
| Critical | Revenue-generating systems, customer data | Real-time | Continuous |
| High | Business-critical applications, sensitive data | Real-time | Continuous |
| Medium | Internal systems, non-sensitive data | Near real-time | Hourly |
| Low | Non-critical systems, public data | Periodic | Daily |

### 3.2 Monitoring Checklist

```yaml
# Monitoring Checklist
monitoring:
  network:
    - traffic_anomalies: true
    - intrusion_detection: true
    - firewall_logs: true
    - dns_monitoring: true
    - vpn_activity: true
  
  endpoint:
    - malware_detection: true
    - behavioral_analysis: true
    - patch_status: true
    - endpoint_compliance: true
  
  cloud:
    - configuration_monitoring: true
    - access_logs: true
    - activity_logs: true
    - compliance_monitoring: true
  
  application:
    - application_logs: true
    - authentication_events: true
    - authorization_events: true
    - error_logs: true
  
  identity:
    - authentication: true
    - failed_logins: true
    - privilege_escalation: true
    - account_changes: true
```

### 3.3 Alert Triage Guidelines

**Common Alerts:**

| Alert Type | Triage Steps | Escalation Criteria |
|------------|--------------|---------------------|
| Malware Detection | 1. Verify detection<br>2. Check quarantine<br>3. Assess impact<br>4. Take action | Critical: Active infection |
| Phishing | 1. Verify email<br>2. Check links/attachments<br>3. Identify recipients<br>4. Take action | Critical: Credential theft |
| Unauthorized Access | 1. Verify access<br>2. Check user<br>3. Review logs<br>4. Take action | Critical: Data exposure |
| Data Exfiltration | 1. Verify data transfer<br>2. Check volume<br>3. Identify destination<br>4. Take action | Critical: Large data volume |
| Privilege Escalation | 1. Verify escalation<br>2. Check user<br>3. Review permissions<br>4. Take action | High: Privilege abuse |

## 4. Incident Reporting

### 4.1 Incident Report Template

```markdown
# Incident Report

## 1. Incident Information

| Field | Value |
|-------|-------|
| Incident ID | [ID] |
| Incident Date | [Date] |
| Incident Time | [Time] |
| Reporter | [Name] |
| Severity | [Critical/High/Medium/Low] |
| Status | [Open/Investigating/Contained/Resolved] |

## 2. Incident Description

### 2.1 Summary
[Brief description]

### 2.2 Timeline

| Time | Event | Action |
|------|-------|--------|
| [Time] | [Event] | [Action] |
| [Time] | [Event] | [Action] |

### 2.3 Impact

| Area | Impact | Severity |
|------|--------|----------|
| Systems | [Description] | [High] |
| Data | [Description] | [High] |
| Business | [Description] | [Medium] |

## 3. Response

### 3.1 Actions Taken

| Action | Owner | Time | Status |
|--------|-------|------|--------|
| [Action] | [Name] | [Time] | [Status] |

### 3.2 Containment

| Action | Owner | Time | Status |
|--------|-------|------|--------|
| [Action] | [Name] | [Time] | [Status] |

### 3.3 Recovery

| Action | Owner | Time | Status |
|--------|-------|------|--------|
| [Action] | [Name] | [Time] | [Status] |

## 4. Lessons Learned

### 4.1 What Worked Well
1. [Item 1]
2. [Item 2]

### 4.2 What Could Be Improved
1. [Item 1]
2. [Item 2]

### 4.3 Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

## 5. Sign Off

| Role | Name | Date |
|------|------|------|
| Incident Handler | | |
| SOC Manager | | |
| CISO | | |
```

---

## T.2: Threat Intelligence Program

### T.2.1: Threat Intelligence Framework

**File:** `security-operations/threat-intelligence.md`

```markdown
# Threat Intelligence Program

## 1. Overview

### 1.1 Program Purpose
To collect, analyze, and disseminate threat intelligence to improve detection and response capabilities.

### 1.2 Program Objectives
1. Identify emerging threats
2. Improve detection capabilities
3. Enable proactive defense
4. Support incident response
5. Inform security decisions

## 2. Threat Intelligence Process

### 2.1 Intelligence Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              THREAT INTELLIGENCE LIFECYCLE                                  │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  1. Planning                                                                                │
│     ├── Define intelligence requirements                                                   │
│     ├── Identify information sources                                                        │
│     └── Establish priorities                                                                │
│                                                                                             │
│  2. Collection                                                                              │
│     ├── Collect from open sources                                                           │
│     ├── Collect from closed sources                                                         │
│     ├── Collect from internal sources                                                       │
│     └── Integrate threat feeds                                                              │
│                                                                                             │
│  3. Processing                                                                              │
│     ├── Normalize data                                                                      │
│     ├── Enrich data                                                                         │
│     ├── Validate data                                                                       │
│     └── Format for analysis                                                                 │
│                                                                                             │
│  4. Analysis                                                                                │
│     ├── Analyze threats                                                                     │
│     ├── Identify patterns                                                                   │
│     ├── Assess impact                                                                       │
│     └── Develop intelligence                                                                │
│                                                                                             │
│  5. Dissemination                                                                           │
│     ├── Share intelligence                                                                  │
│     ├── Update detection rules                                                              │
│     ├── Inform stakeholders                                                                 │
│     └── Enable response                                                                     │
│                                                                                             │
│  6. Feedback                                                                                │
│     ├── Gather feedback                                                                     │
│     ├── Assess effectiveness                                                                │
│     ├── Improve process                                                                     │
│     └── Update requirements                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Intelligence Sources

**Open Source Intelligence (OSINT):**
- Public threat feeds
- Security blogs
- Research papers
- Social media
- Forums
- Security conferences

**Closed Source Intelligence (CSINT):**
- Commercial threat feeds
- Vendor intelligence
- Government intelligence
- Private threat intel groups

**Internal Sources:**
- SIEM data
- Incident data
- Vulnerability data
- Network data
- Endpoint data
- User behavior data

## 3. Threat Intel Product

### 3.1 Intel Product Types

| Product | Description | Frequency | Audience |
|---------|-------------|-----------|----------|
| Strategic | Long-term trends, strategic direction | Quarterly | Leadership |
| Operational | Threats and trends | Weekly | Management |
| Tactical | Specific indicators, TTPs | Daily | Security Team |
| Technical | IOCs, signatures | Real-time | SOC |

### 3.2 Intel Report Template

```yaml
# Threat Intelligence Report
intel_report:
  id: "TI-2024-001"
  date: "2024-03-15"
  title: "Emerging Ransomware Threat"
  classification: "Confidential"
  
  summary:
    - "New ransomware variant detected"
    - "Targeting healthcare sector"
    - "Ransom demands averaging $500K"
  
  threat_actors:
    - name: "Threat Group Alpha"
      motivation: "Financial"
      capability: "High"
      targets:
        - "Healthcare"
        - "Financial Services"
  
  tactics:
    - tactic: "Initial Access"
      technique: "Phishing"
      details: "Spear phishing emails with malicious attachments"
    
    - tactic: "Execution"
      technique: "Malware"
      details: "Ransomware executable"
  
  indicators:
    - type: "Domain"
      value: "malicious-domain.com"
      confidence: "High"
    
    - type: "Hash"
      value: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      confidence: "High"
    
    - type: "IP"
      value: "192.168.1.100"
      confidence: "Medium"
  
  recommendations:
    - "Update firewall rules to block indicators"
    - "Implement additional email filtering"
    - "Enhance endpoint detection rules"
    - "Conduct user awareness training"
  
  action_items:
    - action: "Block IOCs"
      owner: "SOC"
      timeline: "24 hours"
    
    - action: "Update detection rules"
      owner: "Detection Team"
      timeline: "48 hours"
```

---

## T.3: Performance Metrics

### T.3.1: SOC Metrics Dashboard

**File:** `security-operations/soc-metrics.md`

```markdown
# SOC Metrics Dashboard

## 1. Operational Metrics

### 1.1 Alert Metrics

| Metric | Description | Target | Status |
|--------|-------------|--------|--------|
| Alert Volume | Number of alerts per day | <1000 | 🟢 |
| False Positive Rate | % of alerts that are false positives | <10% | 🟡 |
| Alert Triage Time | Average time to triage alerts | <5 minutes | 🟢 |
| Alert Escalation Rate | % of alerts escalated | <20% | 🟢 |

### 1.2 Incident Metrics

| Metric | Description | Target | Status |
|--------|-------------|--------|--------|
| Incident Volume | Number of incidents per month | <50 | 🟢 |
| Incident Severity | Distribution of incidents | Critical <5 | 🟢 |
| MTTD | Mean Time To Detect | <2 hours | 🟢 |
| MTTR | Mean Time To Respond | <4 hours | 🟢 |
| Incident Resolution Rate | % incidents resolved | >90% | 🟢 |

### 1.3 Response Metrics

| Metric | Description | Target | Status |
|--------|-------------|--------|--------|
| First Response Time | Time to first response | <15 minutes | 🟢 |
| Containment Time | Time to contain | <1 hour | 🟡 |
| Eradication Time | Time to eradicate | <4 hours | 🟡 |
| Recovery Time | Time to recover | <24 hours | 🟢 |

## 2. Quality Metrics

### 2.1 Detection Quality

| Metric | Description | Target | Status |
|--------|-------------|--------|--------|
| Detection Accuracy | % of detections confirmed | >80% | 🟢 |
| Detection Coverage | % of threats detected | >90% | 🟡 |
| False Negative Rate | % of missed threats | <5% | 🟢 |

### 2.2 Investigation Quality

| Metric | Description | Target | Status |
|--------|-------------|--------|--------|
| Investigation Thoroughness | % of complete investigations | >90% | 🟢 |
| Evidence Collection | % of incidents with evidence | >95% | 🟢 |
| Documentation Quality | % of incidents documented | >95% | 🟢 |

## 3. Metrics Dashboard

### 3.1 Daily Dashboard

```yaml
# Daily SOC Dashboard
daily_dashboard:
  title: "Daily SOC Performance"
  date: "2024-03-15"
  
  alert_metrics:
    total_alerts: 847
    false_positives: 67
    false_positive_rate: 7.9%
    average_triage_time: "3.2 minutes"
    escalation_rate: 15.3%
  
  incident_metrics:
    total_incidents: 12
    critical: 1
    high: 3
    medium: 5
    low: 3
    mttd: "1.8 hours"
    mttr: "3.5 hours"
  
  response_metrics:
    first_response: "12 minutes"
    containment: "45 minutes"
    eradication: "3.2 hours"
    recovery: "6.5 hours"
```

### 3.2 Weekly Dashboard

```yaml
# Weekly SOC Dashboard
weekly_dashboard:
  title: "Weekly SOC Performance"
  week: "2024-W11"
  
  weekly_alerts:
    total: 5,823
    average_daily: 832
    trend: "Stable"
    false_positive_rate: 8.2%
  
  weekly_incidents:
    total: 87
    critical: 8
    high: 22
    medium: 35
    low: 22
    mttd: "2.1 hours"
    mttr: "3.8 hours"
  
  trend_analysis:
    alert_trend: "Increasing 2% week-over-week"
    incident_trend: "Decreasing 5% week-over-week"
    mttd_trend: "Improving 10% week-over-week"
```

### 3.3 Monthly Dashboard

```yaml
# Monthly SOC Dashboard
monthly_dashboard:
  title: "Monthly SOC Performance"
  month: "March 2024"
  
  monthly_summary:
    total_alerts: 24,850
    total_incidents: 325
    false_positive_rate: 7.8%
    mttd: "2.3 hours"
    mttr: "4.1 hours"
  
  incident_breakdown:
    malware: 45
    phishing: 82
    unauthorized_access: 56
    data_exfiltration: 12
    insider_threat: 8
    ddos: 5
    other: 117
  
  performance_trends:
    mttd: "Improving 15%"
    mttr: "Improving 10%"
    incidents: "Decreasing 5%"
    alerts: "Stable"

  top_indicators:
    - "Failed Login Attempts"
    - "Suspicious Network Connections"
    - "Malware Detection"
    - "Phishing Emails"
```

---

## T.4: Tool Operations

### T.4.1: Tool Administration Guide

**File:** `security-operations/tool-administration.md`

```markdown
# Security Tool Administration Guide

## 1. User Management

### 1.1 Account Provisioning

**Process:**
1. Request submitted
2. Manager approval
3. Security review
4. Account created
5. Access configured
6. User notified

**Request Template:**

```yaml
# Tool Access Request
request:
  user_name: [Name]
  user_email: [Email]
  department: [Department]
  role: [Role]
  tools: [List of tools]
  justification: [Justification]
  manager_approval: [Name]
  security_approval: [Name]
```

### 1.2 Access Control

| Role | Tools | Permissions |
|------|-------|-------------|
| SOC Analyst | SIEM, EDR, Ticketing | Read, Investigate |
| SOC Manager | All tools | Full |
| Incident Responder | SIEM, EDR, Forensic | Full |
| Threat Hunter | SIEM, EDR, Threat Intel | Full |
| Security Engineer | All tools | Full |

## 2. Tool Maintenance

### 2.1 Daily Maintenance

```yaml
# Daily Tool Maintenance
daily:
  - tool: "SIEM"
    tasks:
      - "Check ingestion rates"
      - "Verify log sources"
      - "Review errors"
      - "Check storage"
  
  - tool: "EDR"
    tasks:
      - "Check agent status"
      - "Review detections"
      - "Check coverage"
      - "Verify updates"
  
  - tool: "IAM"
    tasks:
      - "Check MFA adoption"
      - "Review access logs"
      - "Verify authentication"
      - "Check provisioning"
```

### 2.2 Weekly Maintenance

```yaml
# Weekly Tool Maintenance
weekly:
  - tool: "All Tools"
    tasks:
      - "Apply patches"
      - "Review logs"
      - "Check storage"
      - "Verify backups"
      - "Test integrations"
      - "Review performance"
```

### 2.3 Monthly Maintenance

```yaml
# Monthly Tool Maintenance
monthly:
  - tool: "SIEM"
    tasks:
      - "Review rule performance"
      - "Update correlation rules"
      - "Archive old data"
      - "Optimize indexes"
  
  - tool: "EDR"
    tasks:
      - "Review policy effectiveness"
      - "Update prevention policies"
      - "Review exclusions"
      - "Update detection rules"
  
  - tool: "IAM"
    tasks:
      - "Review access rights"
      - "Update role definitions"
      - "Review policies"
      - "Check compliance"
```

## 3. Troubleshooting Guide

### 3.1 Common Issues

**Issue: Tool Not Responding**

**Troubleshooting Steps:**
1. Check service status
   ```bash
   systemctl status tool-service
   ```

2. Check logs
   ```bash
   tail -f /var/log/tool.log
   ```

3. Check resources
   ```bash
   top
   free -h
   df -h
   ```

4. Restart service
   ```bash
   systemctl restart tool-service
   ```

**Issue: Integration Failure**

**Troubleshooting Steps:**
1. Check network connectivity
   ```bash
   ping target-host
   telnet target-host port
   ```

2. Check API connectivity
   ```bash
   curl -X GET https://api.target.com/health
   ```

3. Check credentials
   ```bash
   # Verify API key
   curl -X GET https://api.target.com/auth \
        -H "Authorization: Bearer ${API_KEY}"
   ```

4. Check logs
   ```bash
   tail -f /var/log/integration.log
   ```

### 3.2 Escalation Process

| Issue Level | Response | Escalate To |
|-------------|----------|-------------|
| Level 1 | Initial troubleshooting | Team Lead |
| Level 2 | Advanced troubleshooting | Tool Administrator |
| Level 3 | Vendor support | Vendor |
| Level 4 | Emergency response | Senior Management |
```

---

This concludes Appendix T: Complete Security Operations Reference. This comprehensive reference provides the SOC framework, operational procedures, and metrics needed to effectively operate the Enterprise Cybersecurity Program's security operations.
