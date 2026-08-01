# Primer 3: Security Frameworks Explained
## Enterprise Cybersecurity Architecture & Frameworks
### Understanding SABSA, NIST CSF 2.0, ISO 27001 & MITRE ATT&CK

## Welcome to Security Frameworks

### What Is This Primer?

This primer explains the four major security frameworks we use throughout the series. Think of frameworks as your **recipe book** for security—they provide proven approaches, common language, and structured methods for building security programs.

**By the end of this primer, you'll understand:**
- What security frameworks are and why they matter
- The four frameworks we use (SABSA, NIST CSF 2.0, ISO 27001, MITRE ATT&CK)
- How they work together
- When to use each one

---

## 1. What Is a Security Framework?

### 1.1 The Simple Definition

A **security framework** is a structured approach to managing security. It provides:

- **Standard language** to talk about security
- **Best practices** based on industry experience
- **Maturity models** to assess progress
- **Common control sets** to implement
- **Measurement criteria** to track improvement

### 1.2 Why Use Frameworks?

**Without a Framework:**
- "We do security" but no one knows what that means
- Different teams do different things
- Gaps are unknown until something breaks
- Hard to measure progress
- Difficult to prove compliance

**With a Framework:**
- Clear definition of "what good looks like"
- Everyone uses the same language
- Gaps are identified proactively
- Progress can be measured
- Compliance is demonstrated

### 1.3 The Framework Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FRAMEWORK HIERARCHY                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. BUSINESS FRAMEWORKS (WHY)                                             │
│     • SABSA: Business-driven architecture                                  │
│     • Answers: "What does the business need?"                             │
│                                                                             │
│  2. RISK FRAMEWORKS (HOW TO MANAGE)                                        │
│     • NIST CSF 2.0: Risk management                                        │
│     • Answers: "How do we manage risk?"                                   │
│                                                                             │
│  3. MANAGEMENT FRAMEWORKS (HOW TO OPERATE)                                 │
│     • ISO 27001: Management system                                         │
│     • Answers: "How do we run security systematically?"                   │
│                                                                             │
│  4. THREAT FRAMEWORKS (WHAT TO DEFEND AGAINST)                            │
│     • MITRE ATT&CK: Adversary knowledge                                   │
│     • Answers: "What are we defending against?"                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.4 How They Work Together

Think of frameworks like **building a house**:

| Framework | Role | Analogy |
|-----------|------|---------|
| **SABSA** | Business alignment | "What kind of house do we need?" |
| **NIST CSF** | Risk management | "What risks do we need to address?" |
| **ISO 27001** | Management system | "How do we manage the construction?" |
| **MITRE ATT&CK** | Threat intelligence | "What type of burglars are we guarding against?" |

---

## 2. SABSA: Business-Driven Architecture

### 2.1 What Is SABSA?

**SABSA** (Sherwood Applied Business Security Architecture) is a business-driven security architecture methodology. It's not a framework for what controls to implement—it's a framework for **how to design security architecture**.

**Key Idea:** Security should be driven by business requirements, not technology.

### 2.2 The Six Layers

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SABSA SIX LAYERS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Layer 1: Contextual (Why?)                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Business requirements, risk appetite, environment                  │   │
│  │  Question: "What does the business need?"                          │   │
│  │  Output: Business context document                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│  Layer 2: Conceptual (What?)                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Security strategy, service framework                               │   │
│  │  Question: "What security services do we need?"                    │   │
│  │  Output: Security strategy document                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│  Layer 3: Logical (How?)                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Security services, mechanisms                                      │   │
│  │  Question: "How will we deliver these services?"                   │   │
│  │  Output: Service matrix                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│  Layer 4: Physical (Where?)                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Technology, implementation                                          │   │
│  │  Question: "What technology will we use?"                          │   │
│  │  Output: Technology architecture                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│  Layer 5: Component (Who/Which?)                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Detailed components, configurations                                │   │
│  │  Question: "What specific components do we need?"                  │   │
│  │  Output: Component specifications                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│  Layer 6: Operational (When/Where/How?)                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Procedures, governance, operations                                  │   │
│  │  Question: "How do we run and maintain it?"                       │   │
│  │  Output: Operational procedures                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 The SABSA Traceability Matrix

One of SABSA's most powerful features is **traceability**—every decision at each layer maps to the layer above.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SABSA TRACEABILITY                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Business Requirement              →  Why                                  │
│       │                                                                     │
│       ▼                                                                     │
│  Security Service                  →  What                                 │
│       │                                                                     │
│       ▼                                                                     │
│  Security Mechanism                →  How                                  │
│       │                                                                     │
│       ▼                                                                     │
│  Technology                        →  Where                                │
│       │                                                                     │
│       ▼                                                                     │
│  Component                         →  Who/Which                            │
│       │                                                                     │
│       ▼                                                                     │
│  Procedure                         →  When/Where/How                       │
│                                                                             │
│  Example:                                                                  │
│  "Customer data must be protected" (Business)                              │
│       → "Access to customer data must be controlled" (Service)             │
│       → "Use MFA for customer portal access" (Mechanism)                  │
│       → "Keycloak with WebAuthn" (Technology)                             │
│       → "Keycloak version 23.0+" (Component)                              │
│       → "MFA enrollment during onboarding" (Procedure)                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.4 SABSA in Simple Terms

| Layer | Question | Simple Analogy |
|-------|----------|----------------|
| Contextual | Why? | "The family needs a house" |
| Conceptual | What? | "We need a 3-bedroom house" |
| Logical | How? | "We'll use wood frame, drywall..." |
| Physical | Where? | "We'll use these specific materials" |
| Component | Who/Which? | "We'll use these specific brands" |
| Operational | When/Where/How? | "We'll maintain it this way" |

### 2.5 When to Use SABSA

Use SABSA when you need to:
- Design security architecture from scratch
- Align security with business objectives
- Create traceability between requirements and controls
- Communicate security to business stakeholders
- Build a complete security program

---

## 3. NIST CSF 2.0: Risk Management Framework

### 3.1 What Is NIST CSF?

The **NIST Cybersecurity Framework** (CSF) is a risk management framework developed by the US National Institute of Standards and Technology. It's widely used across industries and government.

**Key Idea:** Manage cybersecurity risk systematically.

### 3.2 The Six Functions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      NIST CSF 2.0 FUNCTIONS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Govern (NEW in 2.0)                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Establish cybersecurity strategy, expectations, and oversight      │   │
│  │  Examples: Policies, roles, risk appetite                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Identify                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Understand organizational assets, risks, and capabilities          │   │
│  │  Examples: Asset inventory, risk assessment                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Protect                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Implement safeguards to ensure delivery of critical services       │   │
│  │  Examples: Access control, encryption, training                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Detect                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Identify the occurrence of a cybersecurity event                   │   │
│  │  Examples: Monitoring, detection rules, threat hunting              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Respond                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Take action regarding a detected cybersecurity incident            │   │
│  │  Examples: IR playbooks, containment, analysis                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Recover                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Restore capabilities and services impaired by an incident          │   │
│  │  Examples: BCP, DR, backups                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 The CSF Categories

Each function has several categories:

| Function | Categories |
|----------|------------|
| **Govern** | GV.OC (Context), GV.RM (Risk), GV.RR (Roles), GV.PO (Policies), GV.OV (Oversight), GV.SC (Supply Chain), GV.AW (Awareness), GV.FI (Feedback) |
| **Identify** | ID.AM (Assets), ID.RA (Risk), ID.BE (Business), ID.GV (Governance), ID.IM (Improvement) |
| **Protect** | PR.AC (Access), PR.AT (Awareness), PR.DS (Data), PR.IP (Process), PR.MA (Maintenance), PR.ND (Network), PR.IR (Response) |
| **Detect** | DE.AE (Anomalies), DE.CM (Monitoring), DE.DP (Processes), DE.AR (Response), DE.DU (Detection), DE.SR (Security) |
| **Respond** | RS.RP (Planning), RS.AN (Analysis), RS.MI (Mitigation), RS.IM (Improvement), RS.CO (Communications) |
| **Recover** | RC.RP (Planning), RC.IM (Improvement), RC.RI (Infrastructure), RC.RC (Communications) |

### 3.4 CSF Implementation Tiers

CSF defines four implementation tiers:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CSF IMPLEMENTATION TIERS                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Tier 1: Partial                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Ad hoc, reactive                                                │   │
│  │  • Limited awareness                                               │   │
│  │  • No formal process                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Tier 2: Risk Informed                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Some awareness                                                  │   │
│  │  • Informal processes                                              │   │
│  │  • Risk-informed decisions                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Tier 3: Repeatable                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Formal process                                                  │   │
│  │  • Consistent execution                                            │   │
│  │  • Risk-aware culture                                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Tier 4: Adaptive                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Continuous improvement                                          │   │
│  │  • Proactive detection and response                                │   │
│  │  • Learning organization                                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.5 CSF in Simple Terms

| Function | Simple Description |
|----------|-------------------|
| **Govern** | "We have a plan and leadership" |
| **Identify** | "We know what we have and what could go wrong" |
| **Protect** | "We put protections in place" |
| **Detect** | "We watch for problems" |
| **Respond** | "We know what to do when something happens" |
| **Recover** | "We can get back to normal" |

### 3.6 When to Use NIST CSF

Use NIST CSF when you need to:
- Assess and manage cybersecurity risk
- Create a risk management program
- Communicate risk to leadership
- Meet regulatory requirements
- Compare your security posture to industry standards

---

## 4. ISO 27001: Management System Framework

### 4.1 What Is ISO 27001?

**ISO 27001** is an international standard for information security management. It specifies requirements for an **Information Security Management System (ISMS)**.

**Key Idea:** Systematically manage information security through a structured management system.

### 4.2 The ISMS Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ISMS COMPONENTS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. ISMS Policy                                                            │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "We are committed to information security"                        ││
│     │  • Scope definition                                               ││
│     │  • Management commitment                                          ││
│     │  • Objectives                                                     ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Risk Assessment                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "What could go wrong?"                                            ││
│     │  • Asset inventory                                                ││
│     │  • Threat identification                                          ││
│     │  • Vulnerability assessment                                      ││
│     │  • Risk scoring                                                   ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Risk Treatment                                                         │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "What are we going to do about it?"                               ││
│     │  • Control selection (Annex A)                                     ││
│     │  • Statement of Applicability (SoA)                               ││
│     │  • Treatment plans                                                 ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  4. Implementation & Operation                                             │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "Do it"                                                            ││
│     │  • Control implementation                                         ││
│     │  • Training and awareness                                          ││
│     │  • Monitoring and measurement                                     ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  5. Monitoring & Review                                                   │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "Are we doing it right?"                                          ││
│     │  • Internal audits                                                ││
│     │  • Management review                                              ││
│     │  • Continuous improvement                                         ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  6. Certification                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "Prove it"                                                         ││
│     │  • Stage 1 audit (documentation)                                  ││
│     │  • Stage 2 audit (implementation)                                ││
│     │  • Certification awarded                                           ││
│     │  • Surveillance audits (ongoing)                                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Annex A Controls

ISO 27001 includes 78 controls across four categories:

| Category | Count | Examples |
|----------|-------|----------|
| **A.5: Organizational** | 37 | Policies, roles, access control |
| **A.6: People** | 8 | Screening, training, discipline |
| **A.7: Physical** | 14 | Physical security, equipment |
| **A.8: Technology** | 34 | Vulnerability management, logging, encryption |

**Key Controls:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      KEY ANNEX A CONTROLS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  A.5.1   Information Security Policy                                       │
│  A.5.15  Access Control Policy                                             │
│  A.5.17  Authentication                                                    │
│  A.5.18  Privileged Access Rights                                          │
│  A.5.25  Secure Development Lifecycle                                     │
│  A.5.29  Security Testing                                                  │
│  A.5.42  Audit Logging                                                     │
│  A.5.54  Backup and Recovery                                              │
│  A.5.55  Cryptographic Controls                                           │
│  A.8.9   Vulnerability Management                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.4 The PDCA Cycle

ISO 27001 follows the **Plan-Do-Check-Act** cycle:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          PDCA CYCLE                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  PLAN                                                              │   │
│  │  • Establish ISMS                                                  │   │
│  │  • Define scope and policy                                        │   │
│  │  • Perform risk assessment                                        │   │
│  │  • Select controls (Annex A)                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                          │                                                  │
│                          ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  DO                                                                │   │
│  │  • Implement and operate ISMS                                     │   │
│  │  • Implement controls                                             │   │
│  │  • Provide training and awareness                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                          │                                                  │
│                          ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  CHECK                                                             │   │
│  │  • Monitor and review ISMS                                        │   │
│  │  • Internal audits                                                │   │
│  │  • Management review                                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                          │                                                  │
│                          ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ACT                                                               │   │
│  │  • Maintain and improve ISMS                                      │   │
│  │  • Implement corrective actions                                  │   │
│  │  • Update risk assessments                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.5 ISO 27001 in Simple Terms

| Component | Simple Description |
|-----------|-------------------|
| **ISMS Policy** | "Our commitment to security" |
| **Risk Assessment** | "What could go wrong and how likely?" |
| **Statement of Applicability** | "Which security measures we're implementing" |
| **Risk Treatment** | "What we're going to do about each risk" |
| **Internal Audit** | "Checking if we're following our own rules" |
| **Management Review** | "Leadership checks if everything is working" |
| **Certification** | "External audit confirms we're doing it right" |

### 4.6 When to Use ISO 27001

Use ISO 27001 when you need to:
- Get formally certified
- Build a systematic security management system
- Meet contractual requirements
- Demonstrate security to customers
- Create a continuous improvement cycle

---

## 5. MITRE ATT&CK: Threat Intelligence Framework

### 5.1 What Is MITRE ATT&CK?

**MITRE ATT&CK** (Adversarial Tactics, Techniques, and Common Knowledge) is a knowledge base of adversary behavior. It provides a common language for understanding threats.

**Key Idea:** Understand how attackers operate so you can defend against them effectively.

### 5.2 The Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MITRE ATT&CK STRUCTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Tactics (The "Why")                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • What is the adversary trying to achieve?                         │   │
│  │  • Examples: Initial Access, Credential Access, Exfiltration       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Techniques (The "How")                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • How does the adversary achieve the tactic?                       │   │
│  │  • Examples: T1078 (Valid Accounts), T1003 (Credential Dumping)    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Procedures (The "Specifics")                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • How is the technique implemented?                                │   │
│  │  • Example: Mimikatz for credential dumping                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 The 14 Tactics

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MITRE 14 TACTICS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Reconnaissance          : Gather information about the target         │
│  2. Resource Development    : Build infrastructure for attack             │
│  3. Initial Access          : Gain entry to the environment               │
│  4. Execution               : Run malicious code                          │
│  5. Persistence             : Maintain foothold                           │
│  6. Privilege Escalation    : Gain higher-level permissions               │
│  7. Defense Evasion         : Avoid detection                             │
│  8. Credential Access       : Steal credentials                           │
│  9. Discovery               : Learn about the environment                 │
│  10. Lateral Movement       : Move through the environment                │
│  11. Collection             : Gather target data                          │
│  12. Command & Control      : Communicate with compromised systems        │
│  13. Exfiltration           : Steal data                                  │
│  14. Impact                 : Disrupt or destroy systems                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.4 Common Techniques

| Technique ID | Name | Tactic | Description |
|--------------|------|--------|-------------|
| T1078 | Valid Accounts | Initial Access | Use stolen credentials |
| T1003 | OS Credential Dumping | Credential Access | Dump passwords from memory |
| T1068 | Exploit for Priv Escalation | Privilege Escalation | Exploit vulnerability to gain admin |
| T1021 | Remote Services | Lateral Movement | Use RDP, SMB, or SSH |
| T1041 | Exfiltration Over C2 | Exfiltration | Steal data over command channel |
| T1486 | Data Encrypted for Impact | Impact | Ransomware encryption |

### 5.5 How to Use MITRE ATT&CK

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      USING MITRE ATT&CK                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Understand Threats                                                      │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • What are attackers doing?                                       ││
│     │  • What techniques are they using?                                ││
│     │  • What threats are most relevant to us?                          ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Map Defenses                                                           │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • What defenses do we have against each technique?               ││
│     │  • Where are our coverage gaps?                                  ││
│     │  • What controls should we prioritize?                           ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Build Detection                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • What log sources can detect each technique?                    ││
│     │  • What detection rules do we need?                               ││
│     │  • How can we test our detection coverage?                       ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  4. Test & Improve                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Run purple team exercises                                      ││
│     │  • Simulate attacks                                               ││
│     │  • Improve detection and response                                ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.6 MITRE ATT&CK in Simple Terms

| Component | Simple Description |
|-----------|-------------------|
| **Tactic** | The attacker's goal |
| **Technique** | How they achieve the goal |
| **Procedure** | The specific tool or method |
| **Coverage** | Which techniques we can detect |
| **Gap** | Which techniques we can't detect |

### 5.7 When to Use MITRE ATT&CK

Use MITRE ATT&CK when you need to:
- Understand adversary behavior
- Build threat-informed defenses
- Prioritize security investments
- Test detection capabilities
- Communicate threats to the team

---

## 6. Framework Integration

### 6.1 How They Work Together

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FRAMEWORK INTEGRATION                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SABSA: Business-Driven Architecture                                       │
│  "What does the business need?"                                           │
│       │                                                                   │
│       ▼                                                                   │
│  NIST CSF 2.0: Risk Management                                            │
│  "How do we manage the risks?"                                           │
│       │                                                                   │
│       ▼                                                                   │
│  MITRE ATT&CK: Threat Intelligence                                        │
│  "What threats should we prioritize?"                                    │
│       │                                                                   │
│       ▼                                                                   │
│  ISO 27001: Management System                                             │
│  "How do we systematically manage it?"                                   │
│       │                                                                   │
│       ▼                                                                   │
│  Implementation: Technology & Controls                                   │
│  "Now we build it"                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 The Integration Matrix

| SABSA Layer | NIST CSF Function | ISO 27001 Annex A | MITRE ATT&CK |
|-------------|-------------------|-------------------|--------------|
| Contextual | Govern, Identify | Risk Assessment | Threat Intel |
| Conceptual | Govern, Identify | A.5 Controls | Tactic Mapping |
| Logical | Protect | A.8 Controls | Technique Mapping |
| Physical | Protect, Detect | A.7 Controls | Detection Rules |
| Component | Protect, Detect | A.8 Controls | Control Implementation |
| Operational | Respond, Recover | A.6 Controls | Response Playbooks |

### 6.3 Real-World Example

**Scenario:** Protecting customer data

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    REAL-WORLD EXAMPLE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. SABSA (Business Context)                                               │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  "Customer data must be protected"                                ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  2. NIST CSF (Risk Management)                                            │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Identify: "Customer PII is a critical asset"                   ││
│     │  • Protect: "We need access controls and encryption"             ││
│     │  • Detect: "We need monitoring for unauthorized access"          ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  3. MITRE ATT&CK (Threats)                                                 │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • T1078: Valid Accounts (stolen credentials)                     ││
│     │  • T1190: Exploit Public-Facing App (API vulnerability)          ││
│     │  • T1041: Exfiltration Over C2 (data theft)                      ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  4. ISO 27001 (Management)                                                │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • A.5.15: Access Control Policy                                 ││
│     │  • A.5.55: Cryptographic Controls                                ││
│     │  • A.5.42: Audit Logging                                         ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│  5. Implementation                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Keycloak for identity                                          ││
│     │  • Encryption for data                                            ││
│     │  • SIEM for monitoring                                           ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Framework Selection Guide

### 7.1 Which Framework to Use When

| Scenario | Primary Framework | Secondary Frameworks |
|----------|-------------------|---------------------|
| **Building new security architecture** | SABSA | NIST CSF, MITRE ATT&CK |
| **Managing cybersecurity risk** | NIST CSF | ISO 27001, MITRE ATT&CK |
| **Getting certified** | ISO 27001 | NIST CSF |
| **Understanding threats** | MITRE ATT&CK | NIST CSF |
| **Compliance requirements** | NIST CSF or ISO 27001 | Depends on requirement |
| **Communicating to leadership** | NIST CSF | SABSA |
| **Building detection rules** | MITRE ATT&CK | NIST CSF |

### 7.2 Framework Maturity Path

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FRAMEWORK MATURITY PATH                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Phase 1: Getting Started                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • NIST CSF 2.0 (Risk management foundation)                      │   │
│  │  • MITRE ATT&CK (Basic threat understanding)                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Phase 2: Building Architecture                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SABSA (Architecture design)                                    │   │
│  │  • NIST CSF (Ongoing risk management)                             │   │
│  │  • MITRE ATT&CK (Threat-informed defense)                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Phase 3: Formal Management                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • ISO 27001 (Management system)                                  │   │
│  │  • All previous frameworks (Integrated)                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Phase 4: Continuous Improvement                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • All frameworks (Operational)                                   │   │
│  │  • Continuous monitoring and improvement                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Key Takeaways

### 8.1 What Each Framework Does

| Framework | Primary Purpose | Core Question |
|-----------|-----------------|---------------|
| **SABSA** | Architecture design | "What does the business need?" |
| **NIST CSF 2.0** | Risk management | "How do we manage risk?" |
| **ISO 27001** | Management system | "How do we run security systematically?" |
| **MITRE ATT&CK** | Threat intelligence | "What are we defending against?" |

### 8.2 How to Remember Them

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EASY TO REMEMBER                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SABSA     →  "The What and Why" (Business alignment)                     │
│  NIST CSF  →  "The How" (Risk management)                                 │
│  ISO 27001 →  "The Who" (Management system)                               │
│  ATT&CK    →  "The Who" (Attackers)                                       │
│                                                                             │
│  Or:                                                                       │
│                                                                             │
│  SABSA     =  "Design the house"                                           │
│  NIST CSF  =  "Plan for risks"                                            │
│  ISO 27001 =  "Manage the process"                                        │
│  ATT&CK    =  "Know the burglars"                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Your Next Steps

1. Understand the role of each framework
2. See how they work together
3. In the series, follow the implementation of all four frameworks
4. Apply them to your own organization

---

## Quick Reference Card

### The Four Frameworks

| Framework | Type | Primary Use |
|-----------|------|-------------|
| **SABSA** | Architecture | Business-driven design |
| **NIST CSF 2.0** | Risk Management | Risk assessment and management |
| **ISO 27001** | Management System | Systematic security management |
| **MITRE ATT&CK** | Threat Intelligence | Understanding adversaries |

### Framework Integration

```
SABSA (Why) → NIST CSF (How to Manage) → ATT&CK (What to Defend) → ISO 27001 (How to Operate)
```

### Key Terms

- **SABSA**: Six layers from business to operations
- **NIST CSF**: Six functions (Govern, Identify, Protect, Detect, Respond, Recover)
- **ISO 27001**: 78 Annex A controls, PDCA cycle
- **MITRE ATT&CK**: 14 tactics, hundreds of techniques
