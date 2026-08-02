# Primer 5: Detection, Response & Resilience Explained
## Enterprise Cybersecurity Architecture & Frameworks
### Understanding SIEM, Detection Engineering, SOAR, Chaos & BCP

## Welcome to Detection, Response & Resilience

### What Is This Primer?

This primer explains the key concepts of detection, response, and resilience—the "last line of defense" in security architecture. In the series, we'll implement these concepts in detail, but this primer gives you the foundation you need.

**By the end of this primer, you'll understand:**
- What SIEM/XDR is and how it works
- How detection engineering identifies threats
- What SOAR does for automated response
- How chaos engineering tests resilience
- Why business continuity matters

---

## 1. The Detection & Response Mindset

### 1.1 Why Detection Matters

No security is perfect. Attacks will happen. The goal is to detect them **quickly** and respond **effectively**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    THE REALITY OF SECURITY                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Traditional thinking:                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "We need to prevent ALL attacks"                                  │   │
│  │  → Prevention is perfect?                                         │   │
│  │  → No need for detection?                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Reality:                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "We CAN'T prevent ALL attacks"                                    │   │
│  │  → Prevention WILL fail                                            │   │
│  │  → We NEED detection and response                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  The Assumption:                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  "Assume Breach" — act as if attackers are already inside          │   │
│  │  → Focus on detecting them                                           │   │
│  │  → Focus on stopping them                                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Key Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| **MTTD** | Mean Time to Detect | < 60 minutes |
| **MTTR** | Mean Time to Respond | < 4 hours |
| **MTTI** | Mean Time to Investigate | < 2 hours |
| **False Positive Rate** | Alerts that are false | < 3% |

### 1.3 The Detection & Response Cycle

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DETECTION & RESPONSE CYCLE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Monitor (SIEM/XDR)                                                     │
│     │                                                                      │
│     ▼                                                                      │
│  2. Detect (Detection Rules)                                               │
│     │                                                                      │
│     ▼                                                                      │
│  3. Alert (Notification)                                                   │
│     │                                                                      │
│     ▼                                                                      │
│  4. Triage (Initial Assessment)                                            │
│     │                                                                      │
│     ▼                                                                      │
│  5. Investigate (Deep Analysis)                                            │
│     │                                                                      │
│     ▼                                                                      │
│  6. Contain (Stop the spread)                                              │
│     │                                                                      │
│     ▼                                                                      │
│  7. Eradicate (Remove the threat)                                          │
│     │                                                                      │
│     ▼                                                                      │
│  8. Recover (Restore systems)                                              │
│     │                                                                      │
│     ▼                                                                      │
│  9. Post-Incident (Learn and improve)                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. SIEM & XDR

### 2.1 What Is SIEM?

**SIEM** (Security Information and Event Management) is a system that collects, analyzes, and reports on security data from across your organization.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SIEM ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  DATA SOURCES                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Application │  │  System    │  │  Security  │  │   Cloud    │     │
│  │    Logs     │  │   Logs     │  │   Logs     │  │   Logs     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     │
│         │              │              │              │                      │
│         └──────────────┼──────────────┼──────────────┘                      │
│                        │             │                                       │
│  ┌─────────────────────▼─────────────▼─────────────────────────────────┐   │
│  │  LOGSTASH (Ingestion)                                               │   │
│  │  • Collects logs from all sources                                  │   │
│  │  • Parses and normalizes data                                      │   │
│  │  • Enriches with context (GeoIP, threat intel)                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  ELASTICSEARCH (Storage)                                            │   │
│  │  • Stores all logs                                                 │   │
│  │  • Indexes for fast searching                                      │   │
│  │  • Retention policies (Hot → Warm → Cold → Delete)                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  ┌─────────────────────────────────▼───────────────────────────────────┐   │
│  │  KIBANA (Visualization)                                             │   │
│  │  • Security dashboards                                             │   │
│  │  • Incident response views                                         │   │
│  │  • Threat hunting workspaces                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 What Is XDR?

**XDR** (Extended Detection and Response) extends SIEM with endpoint detection and response capabilities.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SIEM VS XDR                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SIEM:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Logs from all sources                                           │   │
│  │  • Centralized storage and analysis                               │   │
│  │  • Detection rules                                                │   │
│  │  • Dashboards                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  XDR (SIEM + Endpoint):                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SIEM capabilities                                              │   │
│  │  • Endpoint telemetry (CrowdStrike)                                │   │
│  │  • File, process, registry monitoring                             │   │
│  │  • Endpoint isolation                                             │   │
│  │  • Malware detection                                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Benefit: XDR provides visibility into the endpoint level.                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Detection Engineering

### 3.1 What Is Detection Engineering?

**Detection engineering** is the process of creating, testing, and maintaining rules that identify security threats.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DETECTION ENGINEERING CYCLE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Identify Threat                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Threat intelligence                                            ││
│     │  • Incident post-mortem                                          ││
│     │  • MITRE ATT&CK techniques                                       ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  2. Develop Rule                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Write Sigma rule                                              ││
│     │  • Map to MITRE ATT&CK                                           ││
│     │  • Define false positives                                        ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  3. Test Rule                                                             │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Test with sample data                                         ││
│     │  • Validate against known threats                                ││
│     │  • Check false positive rate                                    ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  4. Deploy Rule                                                           │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Deploy to SIEM                                                ││
│     │  • Monitor initial alerts                                       ││
│     │  • Tune as needed                                               ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  5. Review & Tune                                                         │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Review alerts                                                 ││
│     │  • Adjust thresholds                                            ││
│     │  • Add false positive filters                                   ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Sigma Rules

**Sigma** is a standard format for detection rules. It's vendor-neutral, so rules can be shared and used across different SIEM platforms.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SIGMA RULE EXAMPLE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  title: "Credential Dumping via LSASS"                                     │
│  id: "rule-001"                                                            │
│  status: "production"                                                      │
│  description: "Detects access to LSASS process memory"                    │
│  tags:                                                                     │
│    - attack.t1003                                                          │
│    - attack.credential_access                                              │
│  logsource:                                                                │
│    product: windows                                                        │
│    service: security                                                       │
│  detection:                                                                │
│    selection:                                                              │
│      EventID: 4688                                                         │
│      ProcessName:                                                          │
│        - "*\\rundll32.exe"                                                 │
│        - "*\\powershell.exe"                                               │
│      CommandLine:                                                          │
│        - "*lsass*"                                                         │
│        - "*procdump*"                                                      │
│    condition: selection                                                    │
│  falsepositives:                                                           │
│    - "Legitimate administration tools"                                    │
│  level: high                                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 MITRE ATT&CK Mapping

Each rule maps to a MITRE ATT&CK technique, helping you understand which threats you can detect.

| Rule | MITRE Technique | Tactic |
|------|-----------------|--------|
| Credential Dumping | T1003 | Credential Access |
| Privilege Escalation | T1068 | Privilege Escalation |
| Lateral Movement | T1021 | Lateral Movement |
| Ransomware | T1486 | Impact |
| Data Exfiltration | T1041 | Exfiltration |

---

## 4. SOAR Automation

### 4.1 What Is SOAR?

**SOAR** (Security Orchestration, Automation, and Response) automates incident response workflows.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOAR COMPONENTS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Orchestration:                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Connect security tools together                                 │   │
│  │  • Share data between tools                                        │   │
│  │  • Coordinate responses                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Automation:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Automate repetitive tasks                                        │   │
│  │  • Run playbooks automatically                                      │   │
│  │  • Reduce manual effort                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Response:                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Execute response actions                                        │   │
│  │  • Track incident status                                           │   │
│  │  • Document findings                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Playbook Example

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PLAYBOOK: PHISHING RESPONSE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Trigger: Email security alert                                             │
│                                                                             │
│  Step 1: Alert Triage (5 minutes)                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Receive phishing alert                                          │   │
│  │  • Validate alert is true positive                                 │   │
│  │  • Extract sender, recipient, subject                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Step 2: Email Analysis (10 minutes)                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Extract headers                                                │   │
│  │  • Check attachments (sandbox)                                   │   │
│  │  • Check URLs (reputation)                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Step 3: User Isolation (5 minutes)                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Quarantine mailbox                                             │   │
│  │  • Disable account (if needed)                                   │   │
│  │  • Reset password                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Step 4: Containment (10 minutes)                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Remove malicious email                                         │   │
│  │  • Block sender domain                                            │   │
│  │  • Block malicious URLs                                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Step 5: User Notification (15 minutes)                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Notify affected user                                           │   │
│  │  • Provide phishing awareness tips                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Step 6: Case Documentation (15 minutes)                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Create incident case                                           │   │
│  │  • Document actions                                                │   │
│  │  • Close case                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Chaos Engineering

### 5.1 What Is Chaos Engineering?

**Chaos engineering** is the practice of intentionally injecting failures into systems to test their resilience.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CHAOS ENGINEERING PRINCIPLES                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  It's like a fire drill for your systems:                                  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Simulate failure (like a fire drill)                           │   │
│  │  • Test if systems recover (like testing evacuation)              │   │
│  │  • Find weaknesses (like finding blocked exits)                  │   │
│  │  • Fix problems before real incidents (like fixing exits)        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Key Concept: Control Chaos                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Chaos is carefully controlled, not random                     │   │
│  │  • Tests are planned and scheduled                                │   │
│  │  • Results are measured                                           │   │
│  │  • Each test validates a hypothesis                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Chaos Test Examples

| Test | What Happens | What We Learn |
|------|--------------|---------------|
| **Node Failure** | A Kubernetes node is turned off | Does the system reschedule pods? |
| **Network Partition** | Two services can't communicate | Do circuit breakers work? |
| **DNS Failure** | DNS resolution stops | Does caching work? |
| **Database Failure** | Database connection drops | Does the app handle errors gracefully? |
| **CPU Pressure** | CPU usage spikes | Does auto-scaling work? |
| **Ransomware Sim** | Files are encrypted | Does detection work? |

### 5.3 The Chaos Test Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CHAOS TEST PROCESS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Define Hypothesis                                                      │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "The system should automatically recover from a node failure"     ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  2. Plan Test                                                             │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Test in staging first (then production)                       ││
│     │  • Schedule during low traffic                                   ││
│     │  • Notify stakeholders                                           ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  3. Execute Test                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Inject failure (turn off node)                                ││
│     │  • Monitor system response                                      ││
│     │  • Measure recovery time                                        ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  4. Analyze Results                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Did the system recover?                                       ││
│     │  • How long did it take? (MTTR)                                 ││
│     │  • What went wrong?                                              ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  5. Improve                                                               │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Fix any failures                                              ││
│     │  • Improve recovery time                                        ││
│     │  • Update playbooks                                             ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Business Continuity

### 6.1 What Is Business Continuity?

**Business continuity** is the capability to continue operating during and after disruptive events.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BUSINESS CONTINUITY FRAMEWORK                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Business Impact Analysis (BIA)                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • What systems are critical?                                      │   │
│  │  • How long can we be without them?                               │   │
│  │  • What's the financial impact?                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Recovery Strategies                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Active-Active: Multiple live sites                            │   │
│  │  • Active-Passive: Primary + standby                             │   │
│  │  • Air-Gapped: Offline recovery                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Backup & Recovery                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Immutable backups                                             │   │
│  │  • Air-gapped vaults                                              │   │
│  │  • Regular testing                                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│  Testing & Validation                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Tabletop exercises                                             │   │
│  │  • DR tests                                                       │   │
│  │  • Chaos tests                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 RTO & RPO

| Term | Definition | Example |
|------|------------|---------|
| **RTO** | Recovery Time Objective - Maximum acceptable downtime | "We must be back online within 2 hours" |
| **RPO** | Recovery Point Objective - Maximum acceptable data loss | "We can lose at most 15 minutes of data" |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RTO & RPO VISUALIZED                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Time 0: Incident occurs                                                   │
│     │                                                                      │
│     ▼                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  RPO = 15 minutes                                                  │   │
│  │  ├────────────────────────────────────┤                             │   │
│  │  │  Backups are every 15 minutes                                   │   │
│  │  │  At most 15 minutes of data is lost                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  RTO = 2 hours                                                    │   │
│  │  ├────────────────────────────────────────────────────────────────┤   │
│  │  │  Systems must be restored within 2 hours                       │   │
│  │  │  Downtime is limited to 2 hours                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Backup Strategies

| Strategy | Protection | Speed | Cost |
|----------|-----------|-------|------|
| **Immutable Backups** | WORM protection - can't be modified or deleted | Fast | Medium |
| **Air-Gapped Vaults** | Completely offline - can't be accessed | Slow (12-24h) | High |
| **Cross-Cloud Replication** | Multiple cloud providers | Fast | High |
| **Regular Backups** | Standard protection | Fast | Low |

### 6.4 Recovery Tiers

| Tier | Systems | RTO | RPO |
|------|---------|-----|-----|
| **Tier 0** | Critical (Customer Portal, OT) | 2 hours | 15 minutes |
| **Tier 1** | High (Financial, R&D) | 4 hours | 1 hour |
| **Tier 2** | Medium (HR, Collaboration) | 8 hours | 4 hours |
| **Tier 3** | Low (Public website) | 24 hours | 24 hours |

---

## 7. Key Takeaways

### 7.1 Core Concepts

1. **Detection is essential** because prevention will fail
2. **SIEM/XDR** gives you visibility into what's happening
3. **Detection engineering** creates the rules that find threats
4. **SOAR** automates response to common incidents
5. **Chaos engineering** tests your resilience
6. **Business continuity** plans for the worst

### 7.2 How This Fits in the Series

| Concept | Where We Build It | Part |
|---------|------------------|------|
| SIEM/XDR | ELK Stack + CrowdStrike | Part 4 |
| Detection Rules | Sigma rules | Part 4 |
| Threat Hunting | Hunting playbooks | Part 4 |
| SOAR | TheHive/Cortex playbooks | Part 4 |
| Chaos Engineering | Gremlin + custom tests | Part 4 |
| Business Continuity | BCP, backups, vaults | Part 4 |

### 7.3 The Journey

```
Prevention → Detection → Response → Recovery → Improvement
    │            │           │          │            │
    │     ┌──────▼─────┐     │     ┌────▼────┐       │
    │     │  SIEM/XDR │     │     │  Chaos  │       │
    │     │  Rules    │     │     │  BCP    │       │
    │     └────────────┘     └──────────────┘       │
    └─────────────────────────────────────────────────┘
                 Continuous Learning Loop
```

---

## Quick Reference Card

### Detection & Response
- **SIEM**: Centralized logging and analysis
- **XDR**: SIEM + endpoint detection
- **Detection Rules**: Sigma format, MITRE ATT&CK mapping
- **SOAR**: Automated incident response

### Key Metrics
- **MTTD**: Mean Time to Detect
- **MTTR**: Mean Time to Respond
- **False Positive Rate**: % of alerts that are false

### Chaos Engineering
- Test resilience by injecting failures
- Measure recovery time
- Fix weaknesses
- Repeat

### Business Continuity
- **RTO**: How fast to recover (downtime)
- **RPO**: How much data to lose (data loss)
- **Immutable Backups**: Can't be deleted/modified
- **Air-Gapped Vaults**: Offline storage

### The Detect-Respond-Recover Cycle
1. Monitor (SIEM/XDR)
2. Detect (Rules)
3. Alert (Notification)
4. Triage (Initial)
5. Investigate (Deep)
6. Contain (Stop)
7. Eradicate (Remove)
8. Recover (Restore)
9. Improve (Learn)

---

**Next**: Proceed to the main series with Part 0: Introduction.

---

**[PRIMER 5 COMPLETE]**

---

*This primer is part of the "Enterprise Cybersecurity Architecture & Frameworks" series. Continue to the main series with Part 0 to begin the hands-on implementation.*
