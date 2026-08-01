# Enterprise Cybersecurity Program: Primer 6 - Detection, Response, and Resilience

## Building Your Security Operations Capability

This primer provides a practical guide to building detection, incident response, and business resilience capabilities. These are the capabilities that will protect your organization when threats materialize.

---

## What This Primer Covers

1. **The Security Operations Lifecycle**
2. **Detection: Seeing the Threats**
3. **Response: Taking Action**
4. **Recovery: Restoring Operations**
5. **Business Continuity**
6. **Quick Start Guide**

---

## 1. The Security Operations Lifecycle

### The Continuous Cycle

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SECURITY OPERATIONS LIFECYCLE                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                    DETECT                                          │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Monitoring                                                               │ │    │
│  │  │  • Alerting                                                                 │ │    │
│  │  │  • Threat intelligence                                                      │ │    │
│  │  │  • Anomaly detection                                                         │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│              ┌─────────────────────────────────┴─────────────────────────────────┐          │
│              │                                                                   │          │
│              ▼                                                                   ▼          │
│  ┌─────────────────────────────────────────────────────────────────────┐  ┌─────────────────┐│
│  │                              RESPOND                                 │  │    LEARN        ││
│  │  ┌─────────────────────────────────────────────────────────────────┐ │  │  ┌─────────────┐ ││
│  │  │  • Triage                                                      │ │  │  │  Lessons    │ ││
│  │  │  • Investigation                                               │ │  │  │  learned    │ ││
│  │  │  • Containment                                                 │ │  │  │  Improvement│ ││
│  │  │  • Eradication                                                 │ │  │  └─────────────┘ ││
│  │  └─────────────────────────────────────────────────────────────────┘ │  └─────────────────┘│
│  └─────────────────────────────────────────────────────────────────────┘                    │
│              │                                                                   ▲          │
│              └─────────────────────────────────┬─────────────────────────────────┘          │
│                                                │                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                    RECOVER                                         │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Restore                                                                 │ │    │
│  │  │  • Validate                                                                 │ │    │
│  │  │  • Resume operations                                                        │ │    │
│  │  │  • Post-incident review                                                     │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Why This Matters

- **85%** of organizations have experienced a breach
- **60%** of breaches take months to detect
- **30%** of breaches are never detected
- **$4.45M** average breach cost (IBM 2023)
- **Response time** directly impacts cost

---

## 2. Detection: Seeing the Threats

### Detection Layers

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              DETECTION LAYERS                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  Layer 1: Security Monitoring                                                              │
│  └── SIEM (Security Information and Event Management)                                    │
│      ├── Log collection                                                                    │
│      ├── Event correlation                                                                 │
│      └── Alerting                                                                          │
│                                                                                             │
│  Layer 2: Threat Intelligence                                                               │
│  └── Threat intelligence feeds                                                             │
│      ├── Indicators of compromise (IOCs)                                                  │
│      ├── Threat actor TTPs                                                                 │
│      └── Contextual threat data                                                            │
│                                                                                             │
│  Layer 3: Threat Hunting                                                                   │
│  └── Proactive searching for threats                                                       │
│      ├── Hypothesis-driven                                                                 │
│      ├── Data-driven                                                                       │
│      └── Intelligence-driven                                                               │
│                                                                                             │
│  Layer 4: User and Entity Behavior Analytics                                               │
│  └── Anomaly detection                                                                     │
│      ├── User behavior                                                                     │
│      ├── Device behavior                                                                   │
│      └── Network behavior                                                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### SIEM Implementation Quick Start

| Step | Action | What to Do |
|------|--------|------------|
| 1 | Select SIEM | Splunk, Elastic, Sentinel |
| 2 | Define Requirements | Log sources, retention |
| 3 | Deploy Infrastructure | Hardware/cloud |
| 4 | Integrate Log Sources | All critical systems |
| 5 | Configure Correlation | Detection rules |
| 6 | Build Dashboards | Visualize data |
| 7 | Set Up Alerting | Notifications |

### Critical Log Sources

| Source | What to Log |
|--------|-------------|
| **Firewalls** | Allowed/denied connections |
| **Servers** | OS, application logs |
| **Cloud Services** | AWS CloudTrail, Azure Activity Logs |
| **Applications** | Access, authentication, errors |
| **Identity** | Authentication, authorization |
| **Network** | Traffic, DNS, VPN |

### Alert Triage Guide

| Severity | Response Time | Escalation |
|----------|---------------|------------|
| **Critical** | Immediate | CISO/Executive |
| **High** | <15 minutes | Security Manager |
| **Medium** | <1 hour | SOC Lead |
| **Low** | <4 hours | SOC Analyst |

---

## 3. Response: Taking Action

### Incident Response Process

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              INCIDENT RESPONSE PROCESS                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  1. Detection                                                                               │
│     ├── Identify incident                                                                  │
│     ├── Verify incident                                                                    │
│     └── Classify severity                                                                  │
│                                                                                             │
│  2. Triage                                                                                  │
│     ├── Assess severity                                                                    │
│     ├── Determine impact                                                                   │
│     ├── Assign ownership                                                                   │
│     └── Escalate as needed                                                                 │
│                                                                                             │
│  3. Investigation                                                                           │
│     ├── Gather evidence                                                                     │
│     ├── Analyze root cause                                                                 │
│     ├── Determine scope                                                                     │
│     └── Document findings                                                                  │
│                                                                                             │
│  4. Containment                                                                             │
│     ├── Isolate affected systems                                                           │
│     ├── Block malicious activity                                                           │
│     ├── Prevent spread                                                                     │
│     └── Implement controls                                                                 │
│                                                                                             │
│  5. Eradication                                                                             │
│     ├── Remove threat                                                                      │
│     ├── Clean affected systems                                                             │
│     ├── Patch vulnerabilities                                                              │
│     └── Verify remediation                                                                 │
│                                                                                             │
│  6. Recovery                                                                                │
│     ├── Restore systems                                                                     │
│     ├── Validate functionality                                                             │
│     ├── Monitor for recurrence                                                             │
│     └── Resume operations                                                                  │
│                                                                                             │
│  7. Lessons Learned                                                                         │
│     ├── Conduct post-incident review                                                       │
│     ├── Document findings                                                                  │
│     ├── Identify improvements                                                              │
│     └── Update procedures                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Incident Response Quick Start

1. **Develop Playbooks:** Document procedures
2. **Train Your Team:** Practice regularly
3. **Conduct Tabletop Exercises:** Simulate incidents
4. **Test Your Response:** Validate capabilities
5. **Update Playbooks:** Based on lessons learned

### Playbook Categories

| Type | Examples |
|------|----------|
| **Malware** | Ransomware, virus, trojan |
| **Phishing** | Email, smishing, vishing |
| **Unauthorized Access** | Compromised accounts |
| **Data Breach** | Exfiltration, exposure |
| **Denial of Service** | DDoS |
| **Insider Threat** | Malicious, negligent |

---

## 4. Recovery: Restoring Operations

### Recovery Components

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              RECOVERY COMPONENTS                                           │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  Business Continuity                                                                        │
│  ├── Continue critical operations                                                          │
│  ├── Alternative work arrangements                                                         │
│  └── Temporary processes                                                                    │
│                                                                                             │
│  Disaster Recovery                                                                          │
│  ├── Restore IT systems                                                                     │
│  ├── Restore data                                                                          │
│  └── Failover to recovery site                                                             │
│                                                                                             │
│  Data Recovery                                                                              │
│  ├── Restore from backups                                                                  │
│  ├── Validate data integrity                                                               │
│  └── Verify completeness                                                                    │
│                                                                                             │
│  System Recovery                                                                            │
│  ├── Rebuild systems                                                                       │
│  ├── Reinstall software                                                                     │
│  └── Reconfigure settings                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Recovery Quick Start

1. **Define RTO/RPO:** Recovery time and point objectives
2. **Develop DR Plan:** Document procedures
3. **Implement Backups:** Immutable backups
4. **Test Recovery:** Regular testing
5. **Validate:** Verify functionality
6. **Update:** Based on lessons learned

### Recovery Objectives

| Term | Description | Target |
|------|-------------|--------|
| **RTO** | Time to recover | <4 hours |
| **RPO** | Data loss tolerance | <15 minutes |

### Immutable Backups

- **What:** Backups that cannot be modified
- **Why:** Protect against ransomware
- **How:** WORM storage, access controls
- **Test:** Regular verification

---

## 5. Business Continuity

### BCP Components

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              BUSINESS CONTINUITY PLAN                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  Business Impact Analysis                                                                   │
│  ├── Identify critical functions                                                          │
│  ├── Assess impact                                                                         │
│  └── Determine RTO/RPO                                                                    │
│                                                                                             │
│  Recovery Strategies                                                                        │
│  ├── Alternate processes                                                                   │
│  ├── Backup facilities                                                                     │
│  └── Remote work capabilities                                                              │
│                                                                                             │
│  Plan Development                                                                           │
│  ├── Document procedures                                                                   │
│  ├── Assign responsibilities                                                               │
│  └── Define communication                                                                  │
│                                                                                             │
│  Testing and Exercise                                                                       │
│  ├── Tabletop exercises                                                                    │
│  ├── Technical tests                                                                       │
│  └── Full exercises                                                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### BCP Quick Start

1. **Identify Critical Functions:** What must continue?
2. **Assess Impact:** What happens if they stop?
3. **Develop Strategies:** How will you continue?
4. **Document Plan:** Write it down
5. **Test Plan:** Practice regularly
6. **Update Plan:** Based on lessons

---

## 6. Quick Start Guide

### Detection Quick Start

- [ ] Implement SIEM
- [ ] Integrate log sources
- [ ] Configure alerting
- [ ] Set up threat intelligence
- [ ] Start threat hunting
- [ ] Establish 24/7 monitoring

### Response Quick Start

- [ ] Develop IR playbooks
- [ ] Train response team
- [ ] Conduct tabletop exercises
- [ ] Establish communication channels
- [ ] Define roles and responsibilities
- [ ] Update playbooks regularly

### Recovery Quick Start

- [ ] Define RTO/RPO
- [ ] Implement immutable backups
- [ ] Develop DR plans
- [ ] Test recovery regularly
- [ ] Validate functionality
- [ ] Update plans based on lessons

### Key Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| **MTTD** | Mean time to detect | <2 hours |
| **MTTR** | Mean time to respond | <4 hours |
| **RTO** | Recovery time objective | <4 hours |
| **RPO** | Recovery point objective | <15 minutes |

---

## Quick Reference

### Incident Response Roles

| Role | Responsibility |
|------|----------------|
| **Incident Commander** | Overall coordination |
| **SOC Analysts** | Detection and triage |
| **Incident Responders** | Investigation and response |
| **Communications** | Stakeholder updates |
| **Legal** | Legal guidance |
| **IT Operations** | Technical recovery |

### Key Recovery Documents

| Document | Purpose |
|----------|---------|
| **IR Playbook** | Incident response procedures |
| **DR Plan** | Disaster recovery procedures |
| **BCP Plan** | Business continuity procedures |
| **Communication Plan** | Stakeholder communications |
| **Lessons Learned** | Post-incident improvement |

---

## Next Steps

1. **Complete Part 4** of the main series: Detection, Incident Response & Cyber Resilience
2. **Implement SIEM** for centralized logging
3. **Develop incident response playbooks**
4. **Conduct a tabletop exercise**
5. **Implement immutable backups**
6. **Test your DR plan**

---

*Ready to dive deeper? Proceed to Part 4 of the main series.*
