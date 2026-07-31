# Appendix AU: Complete Security Operations Center (SOC) Reference

## Overview

This appendix provides comprehensive Security Operations Center (SOC) reference material for the Enterprise Cybersecurity Program. It includes SOC structure, operations procedures, shift management, and SOC metrics.

---

## AU.1: SOC Structure and Roles

### AU.1.1: SOC Organization

**File:** `soc/soc-structure.md`

```markdown
# Security Operations Center (SOC) Structure

## 1. Overview

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
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

## 3. Role Definitions

### 3.1 SOC Manager

**Responsibilities:**
- Overall SOC operations
- Strategic planning
- Budget management
- Team management
- Incident escalation

**Skills:**
- Leadership
- Strategic planning
- Incident management
- Communication
- Security operations

**Experience:**
- 8+ years security
- 3+ years management

**Reports to:** CISO

### 3.2 Shift Supervisor

**Responsibilities:**
- Team management
- Escalation handling
- Shift coordination
- Quality assurance
- Training

**Skills:**
- Leadership
- Incident response
- Communication
- Technical expertise

**Experience:**
- 5+ years security
- 2+ years team lead

**Reports to:** SOC Manager

### 3.3 Tier 1 Analyst

**Responsibilities:**
- Alert triage
- Initial investigation
- Documentation
- Escalation

**Skills:**
- Alert handling
- Communication
- Documentation
- Pattern recognition

**Experience:**
- 1-3 years security
- Security+ preferred

**Reports to:** Shift Supervisor

### 3.4 Tier 2 Analyst

**Responsibilities:**
- Deep investigation
- Incident analysis
- Incident coordination
- Reporting

**Skills:**
- Investigation
- Analysis
- Incident response
- Technical writing

**Experience:**
- 3-5 years security
- GCIH preferred

**Reports to:** Shift Supervisor

### 3.5 Tier 3 Analyst

**Responsibilities:**
- Advanced investigation
- Threat hunting
- Mentoring
- Root cause analysis

**Skills:**
- Advanced analysis
- Threat hunting
- Mentoring
- Research

**Experience:**
- 5+ years security
- CISSP/GCIH preferred

**Reports to:** SOC Manager

---

## AU.2: Shift Operations

### AU.2.1: Shift Schedule

**File:** `soc/shift-operations.md`

```markdown
# SOC Shift Operations

## 1. Shift Schedule

### 1.1 Shift Times

```yaml
# Shift Schedule
shift_schedule:
  day_shift:
    time: "6:00 AM - 2:00 PM"
    team_size: 8
    responsibilities: "Full operations"
    supervisor: "Day Shift Supervisor"
  
  afternoon_shift:
    time: "2:00 PM - 10:00 PM"
    team_size: 6
    responsibilities: "Full operations"
    supervisor: "Afternoon Shift Supervisor"
  
  night_shift:
    time: "10:00 PM - 6:00 AM"
    team_size: 4
    responsibilities: "Critical monitoring"
    supervisor: "Night Shift Supervisor"
```

### 1.2 Coverage Requirements

| Requirement | Day | Afternoon | Night |
|-------------|-----|-----------|-------|
| Shift Supervisor | Yes | Yes | Yes |
| Tier 1 Analysts | 4-6 | 3-4 | 2-3 |
| Tier 2 Analysts | 2-3 | 2-3 | 1-2 |
| Tier 3 Analysts | 1-2 | 1-2 | 1 |
| On-Call Support | Yes | Yes | Yes |

## 2. Shift Handover Process

### 2.1 Handover Checklist

- [ ] Review active incidents
- [ ] Review pending alerts
- [ ] Review system health
- [ ] Review maintenance activities
- [ ] Review threat intelligence
- [ ] Review outstanding tickets
- [ ] Document key activities
- [ ] Provide handover briefing

### 2.2 Handover Template

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

threat_intelligence:
  - update: [Update]
    impact: [Impact]

handover_notes:
  - note: [Note]
```

## 3. Daily Operations

### 3.1 Daily Routine

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

---

## AU.3: SOC Operations Procedures

### AU.3.1: Incident Triage Process

**File:** `soc/incident-triage.md`

```markdown
# Incident Triage Process

## 1. Triage Workflow

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

## 2. Severity Classification

### 2.1 Severity Criteria

| Severity | Criteria | Response Time | Escalation |
|----------|----------|---------------|------------|
| Critical | - Business impact<br>- Data breach<br>- Active threat | Immediate | CISO, Executive |
| High | - Significant impact<br>- Potential breach<br>- Contained threat | <15 minutes | SOC Manager |
| Medium | - Limited impact<br>- No breach<br>- Easily contained | <30 minutes | Shift Supervisor |
| Low | - Minimal impact<br>- No breach<br>- Informational | <1 hour | Tier 1 Analyst |

## 3. Triage Guidelines

### 3.1 Common Alerts

| Alert Type | Triage Steps | Escalation Criteria |
|------------|--------------|---------------------|
| Malware Detection | 1. Verify detection<br>2. Check quarantine<br>3. Assess impact<br>4. Take action | Critical: Active infection |
| Phishing | 1. Verify email<br>2. Check links/attachments<br>3. Identify recipients<br>4. Take action | Critical: Credential theft |
| Unauthorized Access | 1. Verify access<br>2. Check user<br>3. Review logs<br>4. Take action | Critical: Data exposure |
| Data Exfiltration | 1. Verify data transfer<br>2. Check volume<br>3. Identify destination<br>4. Take action | Critical: Large data volume |
| Privilege Escalation | 1. Verify escalation<br>2. Check user<br>3. Review permissions<br>4. Take action | High: Privilege abuse |
```

---

## AU.4: SOC Metrics

### AU.4.1: Key Metrics

**File:** `soc/soc-metrics.md`

```markdown
# SOC Metrics

## 1. Alert Metrics

### 1.1 Operational Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Alert Volume | Number of alerts per day | <1000 |
| False Positive Rate | % of alerts that are false positives | <10% |
| Alert Triage Time | Average time to triage alerts | <5 minutes |
| Alert Escalation Rate | % of alerts escalated | <20% |

### 1.2 Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Detection Accuracy | % of detections confirmed | >80% |
| Detection Coverage | % of threats detected | >90% |
| False Negative Rate | % of missed threats | <5% |

## 2. Incident Metrics

### 2.1 Performance Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Incident Volume | Number of incidents per month | <50 |
| MTTD | Mean Time To Detect | <2 hours |
| MTTR | Mean Time To Respond | <4 hours |
| Incident Resolution Rate | % incidents resolved | >90% |

### 2.2 Response Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| First Response Time | Time to first response | <15 minutes |
| Containment Time | Time to contain | <1 hour |
| Eradication Time | Time to eradicate | <4 hours |
| Recovery Time | Time to recover | <24 hours |
```

---

This concludes Appendix AU: Complete Security Operations Center (SOC) Reference. This comprehensive reference provides the SOC structure, shift operations, incident triage procedures, and metrics needed to effectively operate a SOC as part of the Enterprise Cybersecurity Program.
