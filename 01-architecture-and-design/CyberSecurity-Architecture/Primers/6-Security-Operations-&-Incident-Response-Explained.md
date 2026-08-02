# Primer 6: Security Operations & Incident Response Explained
## Enterprise Cybersecurity Architecture & Frameworks
### Understanding SOC, Incident Response & Threat Hunting

## Welcome to Security Operations & Incident Response

### What Is This Primer?

This primer explains the people, processes, and technology behind **security operations**—how organizations detect, respond to, and learn from security incidents.

**By the end of this primer, you'll understand:**
- What a Security Operations Center (SOC) does
- The incident response lifecycle
- How threat hunting works
- Key roles and responsibilities
- How to measure success

---

## 1. The Security Operations Center (SOC)

### 1.1 What Is a SOC?

A **Security Operations Center (SOC)** is a team of security professionals who monitor, detect, and respond to security threats 24/7.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOC COMPONENTS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PEOPLE                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SOC Analysts (Tier 1, 2, 3)                                     │   │
│  │  • Detection Engineers                                             │   │
│  │  • Incident Responders                                             │   │
│  │  • Threat Hunters                                                  │   │
│  │  • SOC Manager                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PROCESSES                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Monitoring and alerting                                        │   │
│  │  • Incident triage                                                │   │
│  │  • Incident response                                              │   │
│  │  • Threat hunting                                                │   │
│  │  • Continuous improvement                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  TECHNOLOGY                                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SIEM/XDR                                                       │   │
│  │  • Detection rules                                                │   │
│  │  • SOAR (automation)                                              │   │
│  │  • Case management                                                │   │
│  │  • Dashboards                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 SOC Tier Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOC TIER STRUCTURE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Tier 1: SOC Analyst (Level 1)                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Monitors alerts                                               │   │
│  │  • Initial triage                                                │   │
│  │  • Escalates to Tier 2                                           │   │
│  │  • Handles routine incidents                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Tier 2: SOC Analyst (Level 2)                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Investigates complex alerts                                   │   │
│  │  • Performs deep analysis                                        │   │
│  │  • Escalates to Tier 3                                           │   │
│  │  • Updates detection rules                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Tier 3: SOC Analyst (Level 3) / Incident Responder                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Handles critical incidents                                     │   │
│  │  • Leads incident response                                       │   │
│  │  • Conducts root cause analysis                                  │   │
│  │  • Mentors junior analysts                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 SOC Operations

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOC OPERATIONS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  24/7 Monitoring                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Continuous monitoring of security events                        │   │
│  │  • Shift rotations (days, nights, weekends)                       │   │
│  │  • Alert triage                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Alert Handling                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Receive alert (SIEM)                                           │   │
│  │  • Validate alert (true or false)                                │   │
│  │  • Classify severity (Critical, High, Medium, Low)               │   │
│  │  • Escalate if needed                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Investigation                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Gather evidence                                                │   │
│  │  • Analyze logs                                                   │   │
│  │  • Correlate events                                               │   │
│  │  • Determine root cause                                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Response                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Execute playbooks                                              │   │
│  │  • Contain threat                                                 │   │
│  │  • Eradicate threat                                               │   │
│  │  • Recover systems                                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Incident Response Lifecycle

### 2.1 The Six Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INCIDENT RESPONSE LIFECYCLE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. Preparation                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │  • Build IR team                                             │ │   │
│  │  │  • Create playbooks                                          │ │   │
│  │  │  • Train team                                                │ │   │
│  │  │  • Set up tools                                              │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  2. Detection & Analysis                                          │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │  • Monitor alerts                                            │ │   │
│  │  │  • Triage alerts                                             │ │   │
│  │  │  • Investigate                                               │ │   │
│  │  │  • Determine scope                                           │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  3. Containment                                                   │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │  • Isolate affected systems                                 │ │   │
│  │  │  • Block malicious IPs                                      │ │   │
│  │  │  • Disable compromised accounts                             │ │   │
│  │  │  • Short-term vs long-term                                 │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  4. Eradication                                                   │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │  • Remove malware                                           │ │   │
│  │  │  • Patch vulnerabilities                                   │ │   │
│  │  │  • Clean infected systems                                  │ │   │
│  │  │  • Verify cleanup                                           │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  5. Recovery                                                      │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │  • Restore systems                                          │ │   │
│  │  │  • Validate functionality                                   │ │   │
│  │  │  • Monitor for recurrence                                   │ │   │
│  │  │  • Resume operations                                        │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  6. Post-Incident Activity                                        │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │  • Root cause analysis                                      │ │   │
│  │  │  • Lessons learned                                          │ │   │
│  │  │  • Update playbooks                                         │ │   │
│  │  │  • Improve controls                                         │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Incident Severity Classification

| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| **CRITICAL** | Active breach, data loss ongoing | Immediate | Ransomware, Data breach |
| **HIGH** | Likely breach, immediate action needed | < 15 min | Phishing, Compromised credentials |
| **MEDIUM** | Suspicious activity, investigation needed | < 1 hour | Unusual network traffic |
| **LOW** | Potential issue, monitoring | < 4 hours | Policy violations |

### 2.3 Incident Response Roles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INCIDENT RESPONSE ROLES                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Incident Commander                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Overall incident management                                     │   │
│  │  • Decision making                                                 │   │
│  │  • Communication                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Scribe                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Documentation                                                   │   │
│  │  • Timeline tracking                                               │   │
│  │  • Action tracking                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Technical Lead                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Technical investigation                                         │   │
│  │  • Forensics                                                       │   │
│  │  • Remediation                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Communication Lead                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Internal communication                                         │   │
│  │  • External communication (PR, customers)                         │   │
│  │  • Regulatory notifications                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Legal Counsel                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Legal guidance                                                 │   │
│  │  • Regulatory compliance                                          │   │
│  │  • Privilege preservation                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Threat Hunting

### 3.1 What Is Threat Hunting?

**Threat hunting** is the proactive search for threats that have evaded existing detection controls. Unlike reactive detection, hunting is driven by hypotheses and curiosity.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    REACTIVE VS PROACTIVE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  REACTIVE (Detection)                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Alert → Investigate → Respond                                    │   │
│  │                                                                     │   │
│  │  "The alarm went off. What happened?"                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PROACTIVE (Hunting)                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Hypothesis → Search → Discover                                    │   │
│  │                                                                     │   │
│  │  "What might be happening that we don't know about?"               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  The Difference:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Detection finds what we know to look for                        │   │
│  │  • Hunting finds what we didn't know to look for                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 The Hunting Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    THREAT HUNTING PROCESS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Hypothesis Formulation                                                 │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Based on threat intelligence                                  ││
│     │  • Based on detection gaps                                       ││
│     │  • Based on suspicious patterns                                 ││
│     │  • Example: "Attackers might be using credential dumping"        ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  2. Data Collection                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Identify relevant data sources                                ││
│     │  • Query logs and telemetry                                      ││
│     │  • Collect evidence                                              ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  3. Analysis & Investigation                                               │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Analyze patterns                                              ││
│     │  • Identify anomalies                                            ││
│     │  • Correlate events                                              ││
│     │  • Follow leads                                                 ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  4. Discovery & Validation                                                 │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Confirm or refute hypothesis                                  ││
│     │  • Classify findings                                            ││
│     │  • Escalate if threat                                            ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  5. Improvement                                                            │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Update detection rules                                       ││
│     │  • Refine hunting procedures                                    ││
│     │  • Share intelligence                                            ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Hunting Types

| Type | Description | Example |
|------|-------------|---------|
| **Intel-Based** | Driven by threat intelligence | "APT groups are using this technique" |
| **Data-Driven** | Driven by data analysis | "Unusual outbound connections" |
| **TTP-Based** | Driven by attacker behavior | "Credential dumping patterns" |
| **Analytics-Based** | Driven by statistical anomalies | "User behavior anomalies" |

### 3.4 Hunting Tools

| Tool | Purpose |
|------|---------|
| **SIEM (Kibana)** | Query and analyze logs |
| **Jupyter Notebooks** | Interactive data analysis |
| **Python** | Custom analytics |
| **MITRE ATT&CK Navigator** | TTP mapping |
| **Threat Intelligence Feeds** | Context and indicators |

---

## 4. Key Incident Types & How to Handle Them

### 4.1 Phishing

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHISHING INCIDENT RESPONSE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Detection:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • User reports suspicious email                                   │   │
│  │  • Email gateway flags malicious email                            │   │
│  │  • SIEM detects credential compromise                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Response:                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. Quarantine affected mailbox                                    │   │
│  │  2. Disable compromised account                                    │   │
│  │  3. Reset password                                                 │   │
│  │  4. Revoke all sessions                                           │   │
│  │  5. Remove malicious email                                        │   │
│  │  6. Block sender                                                  │   │
│  │  7. Notify user                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Prevention:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • MFA for all users                                              │   │
│  │  • Phishing simulations                                           │   │
│  │  • Security awareness training                                    │   │
│  │  • Email filtering                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Ransomware

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RANSOMWARE INCIDENT RESPONSE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Detection:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • XDR detects ransomware activity                                │   │
│  │  • User reports encrypted files                                   │   │
│  │  • SIEM detects suspicious file activity                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Response:                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. Isolate affected network segments                              │   │
│  │  2. Isolate infected endpoints                                     │   │
│  │  3. Block C2 communication                                         │   │
│  │  4. Revoke compromised credentials                                 │   │
│  │  5. Restore from immutable backups                                 │   │
│  │  6. Reimage affected systems                                      │   │
│  │  7. Monitor for recurrence                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Prevention:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Immutable backups                                              │   │
│  │  • Network segmentation                                           │   │
│  │  • Endpoint protection (XDR)                                      │   │
│  │  • Patch management                                               │   │
│  │  • Least privilege                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Compromised Credentials

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPROMISED CREDENTIALS RESPONSE                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Detection:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SIEM detects unusual logins                                    │   │
│  │  • User reports suspicious activity                               │   │
│  │  • UEBA detects anomaly                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Response:                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. Disable user account                                           │   │
│  │  2. Force password reset                                           │   │
│  │  3. Revoke all active sessions                                    │   │
│  │  4. Reset MFA tokens                                              │   │
│  │  5. Rotate associated API keys                                    │   │
│  │  6. Review recent activity                                        │   │
│  │  7. Notify user                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Prevention:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • MFA for all users                                              │   │
│  │  • Strong password policy                                         │   │
│  │  • Zero Trust architecture                                        │   │
│  │  • Continuous verification                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Key Metrics for Security Operations

### 5.1 Performance Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| **MTTD** | Mean Time to Detect | < 60 minutes |
| **MTTR** | Mean Time to Respond | < 4 hours |
| **MTTI** | Mean Time to Investigate | < 2 hours |
| **False Positive Rate** | Alerts that are false | < 3% |
| **Alert Volume** | Number of alerts per day | < 100/day |

### 5.2 Effectiveness Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| **Detection Coverage** | % of MITRE ATT&CK techniques covered | > 80% |
| **Incident Severity** | % of incidents that are critical | < 5% |
| **Repeat Incidents** | Incidents of the same type recurring | Decreasing |
| **Remediation Time** | Time to fix vulnerabilities | < 30 days |

### 5.3 Maturity Metrics

| Level | Description | Indicators |
|-------|-------------|------------|
| **Level 1: Initial** | Ad hoc, reactive | No formal processes |
| **Level 2: Repeatable** | Some processes | Playbooks exist |
| **Level 3: Defined** | Formal processes | Consistent execution |
| **Level 4: Managed** | Measured and improved | Metrics tracked |
| **Level 5: Optimized** | Continuous improvement | Self-healing |

---

## 6. Key Takeaways

### 6.1 Core Concepts

1. **The SOC** is the nerve center for security operations
2. **Incident response** follows a structured lifecycle (Prepare → Detect → Contain → Eradicate → Recover → Improve)
3. **Threat hunting** proactively finds threats before they trigger alerts
4. **Automation (SOAR)** speeds up response and reduces manual effort
5. **Metrics** measure effectiveness and drive improvement
6. **Continuous improvement** is essential—learn from every incident

### 6.2 How This Fits in the Series

| Concept | Where We Build It | Part |
|---------|------------------|------|
| SOC Operations | SIEM/XDR, SOAR | Part 4 |
| Incident Response | IR playbooks, SOAR | Part 4 |
| Threat Hunting | Hunting methodology, playbooks | Part 4 |
| Metrics | SIEM dashboards, reporting | Part 4 |
| Automation | SOAR playbooks | Part 4 |

---

## Quick Reference Card

### Incident Severity
| Level | Response Time |
|-------|---------------|
| CRITICAL | Immediate |
| HIGH | < 15 min |
| MEDIUM | < 1 hour |
| LOW | < 4 hours |

### Incident Response Phases
1. Preparation
2. Detection & Analysis
3. Containment
4. Eradication
5. Recovery
6. Post-Incident

### Key Metrics
- **MTTD**: Time to detect
- **MTTR**: Time to respond
- **False Positive Rate**: % of false alerts

### Threat Hunting
- Proactive, not reactive
- Hypothesis-driven
- Uses data analysis
- Finds unknown threats

### SOC Tiers
- **Tier 1**: Initial triage
- **Tier 2**: Investigation
- **Tier 3**: Critical incidents

---

**Next**: Proceed to the main series with Part 0: Introduction.

---

**[PRIMER 6 COMPLETE]**

---

*This primer is part of the "Enterprise Cybersecurity Architecture & Frameworks" series. You now have the foundation to understand all six primers. Continue to the main series with Part 0 to begin the hands-on implementation of the complete security architecture.*
