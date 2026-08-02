# Enterprise Cybersecurity Architecture & Frameworks
## Complete Student Notes
### Comprehensive Reference & Study Guide

## About These Notes

These notes are designed to accompany the "Enterprise Cybersecurity Architecture & Frameworks" series. They provide a comprehensive reference for all key concepts, frameworks, technologies, and best practices covered in the course.

**How to Use These Notes:**
- **Before Class:** Preview the notes to understand key concepts
- **During Class:** Follow along and add your own annotations
- **After Class:** Review and reinforce your learning
- **For Certification:** Use as a study guide for certification exams

---

# PART 1: FOUNDATIONS OF SECURE ARCHITECTURE

---

## 1.1 SABSA Framework
### Key Concepts & Takeaways

---

### What is SABSA?

**SABSA (Sherwood Applied Business Security Architecture)** is a business-driven security architecture methodology.

**Core Principle:** Security should be driven by business requirements, not technology.

**Six Layers:**

| Layer | Question | Description |
|-------|----------|-------------|
| **Contextual** | WHY? | Business requirements, risk appetite |
| **Conceptual** | WHAT? | Security strategy, service framework |
| **Logical** | HOW? | Security services, mechanisms |
| **Physical** | WHERE? | Technology, implementation |
| **Component** | WHO/WHICH? | Specific components, configurations |
| **Operational** | WHEN/WHERE/HOW? | Procedures, governance |

**Key Insight:** Each layer maps to the layer above and below, creating complete traceability from business requirements to operational procedures.

---

### The Traceability Matrix

The traceability matrix is SABSA's most powerful feature. It connects:

```
Business Requirement
    │
    ▼
Security Service
    │
    ▼
Security Mechanism
    │
    ▼
Technology
    │
    ▼
Component
    │
    ▼
Operational Procedure
```

**Example Traceability:**
- **Business:** "Customer data must be protected"
- **Service:** "Access to customer data must be controlled"
- **Mechanism:** "Use MFA for customer portal access"
- **Technology:** "Keycloak with WebAuthn"
- **Component:** "Keycloak v23.0+ configured with MFA"
- **Procedure:** "MFA enrollment during onboarding"

---

### SABSA in Practice

**When to Use SABSA:**
- Designing security architecture from scratch
- Aligning security with business objectives
- Creating traceability between requirements and controls
- Communicating security to business stakeholders
- Building a complete security program

**Key Deliverables:**
1. Business context document
2. Security strategy document
3. Service matrix
4. Technology architecture
5. Component specifications
6. Operational procedures

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 1.2 NIST CSF 2.0
### Key Concepts & Takeaways

---

### What is NIST CSF?

**NIST CSF (Cybersecurity Framework)** is a risk management framework developed by the US National Institute of Standards and Technology.

**Core Principle:** Manage cybersecurity risk systematically.

**The Six Functions:**

| Function | Purpose |
|----------|---------|
| **Govern** | Establish cybersecurity strategy, expectations, and oversight |
| **Identify** | Understand organizational assets, risks, and capabilities |
| **Protect** | Implement safeguards to ensure delivery of critical services |
| **Detect** | Identify the occurrence of a cybersecurity event |
| **Respond** | Take action regarding a detected cybersecurity incident |
| **Recover** | Restore capabilities and services impaired by an incident |

**Key Insight:** Govern is NEW in CSF 2.0, recognizing cybersecurity as a business leadership responsibility.

---

### CSF Categories & Subcategories

**Govern (GV):**
- GV.OC: Organizational Context
- GV.RM: Risk Management Strategy
- GV.RR: Roles & Responsibilities
- GV.PO: Policies & Procedures
- GV.OV: Oversight
- GV.SC: Supply Chain Risk
- GV.AW: Awareness & Training
- GV.FI: Feedback & Improvement

**Identify (ID):**
- ID.AM: Asset Management
- ID.RA: Risk Assessment
- ID.BE: Business Environment
- ID.GV: Governance & Risk
- ID.IM: Improvement

**Protect (PR):**
- PR.AC: Access Control
- PR.AT: Awareness & Training
- PR.DS: Data Security
- PR.IP: Information Protection
- PR.MA: Maintenance
- PR.ND: Network Security
- PR.IR: Incident Response

**Detect (DE):**
- DE.AE: Anomalies & Events
- DE.CM: Continuous Monitoring
- DE.DP: Detection Processes
- DE.AR: Anomaly Response
- DE.DU: Detection of Unauthorized Activity
- DE.SR: Security Monitoring

**Respond (RS):**
- RS.RP: Response Planning
- RS.AN: Analysis
- RS.MI: Mitigation
- RS.IM: Improvement
- RS.CO: Communications

**Recover (RC):**
- RC.RP: Recovery Planning
- RC.IM: Improvement
- RC.RI: Recovery Infrastructure
- RC.RC: Recovery Communications

---

### CSF Implementation Tiers

| Tier | Name | Description |
|------|------|-------------|
| 1 | Partial | Ad hoc, reactive, limited awareness |
| 2 | Risk Informed | Some awareness, informal processes |
| 3 | Repeatable | Formal process, consistent execution |
| 4 | Adaptive | Continuous improvement, proactive |

---

### CSF-SABSA Integration

| SABSA Layer | CSF Function | Example |
|-------------|--------------|---------|
| Contextual | Govern, Identify | Business context, risk appetite |
| Conceptual | Govern, Identify | Security strategy, service framework |
| Logical | Protect | Access control, data security |
| Physical | Protect, Detect | Technology controls, monitoring |
| Component | Protect, Detect | Components, configurations |
| Operational | Respond, Recover | Procedures, governance |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 1.3 ISO 27001 ISMS
### Key Concepts & Takeaways

---

### What is ISO 27001?

**ISO 27001** is an international standard for information security management. It specifies requirements for an **Information Security Management System (ISMS)** .

**Core Principle:** Systematically manage information security through a structured management system.

**The ISMS Components:**

| Component | Purpose |
|-----------|---------|
| **ISMS Policy** | "We are committed to information security" |
| **Risk Assessment** | "What could go wrong?" |
| **Risk Treatment** | "What are we going to do about it?" |
| **Statement of Applicability (SoA)** | "Which controls apply?" |
| **Implementation & Operation** | "Do it" |
| **Monitoring & Review** | "Are we doing it right?" |
| **Certification** | "Prove it" |

---

### Annex A Controls

**78 controls in four categories:**

| Category | Count | Examples |
|----------|-------|----------|
| **A.5 Organizational** | 37 | Policies, roles, access control |
| **A.6 People** | 8 | Screening, training, discipline |
| **A.7 Physical** | 14 | Physical security, equipment |
| **A.8 Technology** | 34 | Vulnerability mgmt, logging, encryption |

**Key Controls:**
- A.5.1: Information Security Policy
- A.5.15: Access Control Policy
- A.5.17: Authentication
- A.5.18: Privileged Access Rights
- A.5.25: Secure Development Lifecycle
- A.5.29: Security Testing
- A.5.42: Audit Logging
- A.5.54: Backup and Recovery
- A.5.55: Cryptographic Controls
- A.8.9: Vulnerability Management

---

### The PDCA Cycle

```
┌─────────────────────────────────────────────────────────────┐
│                      PDCA CYCLE                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PLAN: Establish ISMS                                      │
│  ├── Define scope and policy                              │
│  ├── Perform risk assessment                              │
│  ├── Select controls (Annex A)                           │
│  └── Create risk treatment plan                          │
│                                                             │
│  DO: Implement and Operate                                 │
│  ├── Implement controls                                   │
│  ├── Operate security processes                            │
│  └── Provide training and awareness                       │
│                                                             │
│  CHECK: Monitor and Review                                 │
│  ├── Internal audits                                      │
│  ├── Management review                                    │
│  └── Monitor security incidents                           │
│                                                             │
│  ACT: Maintain and Improve                                 │
│  ├── Implement corrective actions                         │
│  ├── Update risk assessments                              │
│  └── Improve controls and processes                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Risk Scoring Matrix

| Likelihood | Impact 1 | Impact 2 | Impact 3 | Impact 4 | Impact 5 |
|------------|----------|----------|----------|----------|----------|
| 1 (Very Low) | 1 | 2 | 3 | 4 | 5 |
| 2 (Low) | 2 | 4 | 6 | 8 | 10 |
| 3 (Moderate) | 3 | 6 | 9 | 12 | 15 |
| 4 (High) | 4 | 8 | 12 | 16 | 20 |
| 5 (Very High) | 5 | 10 | 15 | 20 | 25 |

**Risk Levels:**
- **1-4:** LOW (Accept/Monitor)
- **5-9:** MEDIUM (Treat within 6 months)
- **10-14:** HIGH (Treat within 3 months)
- **15-25:** CRITICAL (Treat immediately)

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 1.4 Threat Modeling
### Key Concepts & Takeaways

---

### What is Threat Modeling?

**Threat modeling** is a systematic approach to identifying threats and vulnerabilities in systems.

**Four Methodologies:**

| Methodology | Best For | Key Feature |
|-------------|----------|-------------|
| **STRIDE** | Component-level analysis | Six threat categories |
| **PASTA** | Business-aligned risk assessment | 7 stages from business to risk |
| **Attack Trees** | Visual attack path analysis | Tree-based visualization |
| **MITRE ATT&CK** | Threat-informed defense | Knowledge base of adversary behavior |

---

### STRIDE

| Category | Description | Example | Mitigation |
|----------|-------------|---------|------------|
| **S**poofing | Pretending to be someone else | Credential theft | MFA, authentication |
| **T**ampering | Modifying data | SQL injection | Input validation, encryption |
| **R**epudiation | Denying actions | User denies transaction | Audit logging |
| **I**nfo Disclosure | Exposing data | Data breach | Encryption, access controls |
| **D**oS | Overwhelming system | DDoS attack | Rate limiting, auto-scaling |
| **E**levation | Gaining higher privileges | Admin access | Least privilege, JIT |

---

### PASTA (7 Stages)

1. **Define Business Objectives** - What are we protecting and why?
2. **Define Technical Scope** - What's in the system?
3. **Application Decomposition** - How does it work?
4. **Threat Analysis** - What threats exist?
5. **Vulnerability Analysis** - What weaknesses exist?
6. **Attack Modeling** - How could attacks happen?
7. **Risk & Impact Analysis** - What's the business impact?

---

### Attack Trees

**Structure:**
- Root node: Attacker's ultimate goal
- OR nodes: Alternative paths
- AND nodes: Multiple conditions required

**Example - Credential Theft:**
```
                    [Gain Access]
                    /     |     \
            [Phishing] [Brute Force] [Credential Reuse]
               |            |             |
           [User Click] [Weak Password] [Password Reuse]
               |            |             |
           [MFA Bypass] [No Lockout]  [Breached Creds]
```

---

### MITRE ATT&CK (14 Tactics)

| Tactic | Description | Key Techniques |
|--------|-------------|----------------|
| Reconnaissance | Gather information | T1595 Active Scanning |
| Resource Development | Build infrastructure | T1583 Acquire Infrastructure |
| Initial Access | Gain entry | T1078 Valid Accounts, T1190 Exploit Public App |
| Execution | Run malicious code | T1059 Command & Scripting Interpreter |
| Persistence | Maintain foothold | T1053 Scheduled Task/Job |
| Privilege Escalation | Gain higher permissions | T1068 Exploit for Priv Escalation |
| Defense Evasion | Avoid detection | T1578 Modify Cloud Infrastructure |
| Credential Access | Steal credentials | T1003 OS Credential Dumping |
| Discovery | Learn environment | T1087 Account Discovery |
| Lateral Movement | Move through environment | T1021 Remote Services |
| Collection | Gather target data | T1119 Automated Collection |
| Command & Control | Communicate with compromised systems | T1071 Application Layer Protocol |
| Exfiltration | Steal data | T1041 Exfiltration Over C2 |
| Impact | Disrupt/destroy | T1486 Data Encrypted for Impact |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

# PART 2: ZERO TRUST & IDENTITY

---

## 2.1 Zero Trust Architecture
### Key Concepts & Takeaways

---

### What is Zero Trust?

**Zero Trust** is a security model that eliminates implicit trust and continuously verifies every access request.

**Core Principles:**

| Principle | Description |
|-----------|-------------|
| **Verify Explicitly** | Always authenticate and authorize based on all available data |
| **Least Privilege** | Give the minimum access needed—nothing more |
| **Assume Breach** | Design as if attackers are already inside |

---

### The Four Components

| Component | Role | Implementation |
|-----------|------|----------------|
| **PDP** (Policy Decision Point) | Makes access decisions | OPA |
| **PEP** (Policy Enforcement Point) | Enforces decisions | Istio, Kong, Calico |
| **PAP** (Policy Administration Point) | Manages policies | Git + CI/CD |
| **PIP** (Policy Information Point) | Provides context | Keycloak, CrowdStrike |

---

### The Zero Trust Flow

1. User requests access
2. PEP intercepts request
3. PIP gathers context (identity, device, location, behavior)
4. PDP evaluates policy
5. Decision: ALLOW, DENY, or CHALLENGE
6. PEP enforces decision
7. Decision logged to SIEM

---

### Continuous Verification

**What It Checks:**
- Session age (max 8 hours)
- Inactivity (max 15 minutes)
- Device posture
- Geographic anomalies
- Behavioral anomalies

**Risk Scoring:**
- 0-30: LOW → Continue
- 31-60: MEDIUM → Monitor
- 61-80: HIGH → Step-up authentication
- 81-100: CRITICAL → Terminate session

---

### Zero Trust Implementation Roadmap

| Phase | Timeline | Activities |
|-------|----------|------------|
| Foundation | Months 1-3 | OPA deployment, basic policies |
| Workload Protection | Months 4-6 | Istio, mTLS, PEP |
| User Access | Months 7-9 | IdP integration, user policies |
| Advanced | Months 10-12 | Continuous verification, risk scoring |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 2.2 Identity & Access Management
### Key Concepts & Takeaways

---

### What is IAM?

**Identity and Access Management (IAM)** is the framework of policies and technologies that ensures the right people have the right access to the right resources at the right time.

**Key Components:**
- Identity Provider (IdP)
- Authentication
- Authorization
- Identity Lifecycle (JML)

---

### Authentication vs Authorization

| | Authentication | Authorization |
|---|----------------|---------------|
| **Question** | Who are you? | What can you do? |
| **When** | First | Second |
| **Example** | Login with MFA | Access control policy |
| **Technology** | Keycloak | OPA |

---

### Keycloak Features

- OAuth 2.1/OIDC support
- SAML 2.0 federation
- SCIM 2.0 provisioning
- MFA (WebAuthn + TOTP)
- User federation with LDAP/AD

**Authentication Flow:**
1. User accesses application
2. Redirected to Keycloak
3. User authenticates (MFA)
4. Keycloak issues JWT
5. Application validates JWT
6. User granted access

---

### JML (Joiner-Mover-Leaver)

| Event | Actions |
|-------|---------|
| **Joiner** | HR triggers → SCIM creates account → Groups assigned → MFA enrollment |
| **Mover** | HR updates → SCIM updates account → Access reviewed |
| **Leaver** | HR terminates → SCIM disables account → Sessions revoked |

---

### RBAC vs ABAC

| | RBAC | ABAC |
|---|------|------|
| **Based On** | Roles | Attributes |
| **Example** | "Admin" role | User+Resource+Environment |
| **Advantage** | Simple to manage | Fine-grained |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 2.3 Privileged Access Management
### Key Concepts & Takeaways

---

### What is PAM?

**Privileged Access Management (PAM)** manages and monitors access to critical systems by privileged users.

**Key Concepts:**

| Concept | Description |
|---------|-------------|
| **JIT (Just-In-Time)** | Temporary privileged access |
| **JEA (Just-Enough-Administration)** | Minimal permissions for privileged tasks |
| **Session Recording** | Audit trail for privileged actions |
| **Credential Rotation** | Automatic password rotation |
| **Break-Glass** | Emergency access with strict controls |

---

### HashiCorp Vault

**Features:**
- Secrets management
- Dynamic credentials
- JIT workflows
- Session recording
- Audit logging

**JIT Workflow:**
1. User requests privileged access
2. Approval workflow (manager + security)
3. Vault generates dynamic credentials
4. Session recording starts
5. Time-bound access (15 min max)
6. Auto-expiration and cleanup

---

### Break-Glass Access

**Purpose:** Emergency access when normal processes can't be followed

**Process:**
1. Emergency declared
2. User requests break-glass
3. Session activated (30 min)
4. Alerts triggered immediately
5. Actions logged
6. Post-incident review required

**Access Requirements:**
- 2-person approval required
- Justification required
- 30-minute session limit
- Immediate alerts
- Full audit trail

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 2.4 Micro-segmentation & SDP
### Key Concepts & Takeaways

---

### What is Micro-segmentation?

**Micro-segmentation** is fine-grained network isolation at the workload level.

**Benefits:**
- Limits blast radius
- Prevents lateral movement
- Enforces least privilege network access
- Enables default deny

**Technologies:**
- **Calico:** Network policies in Kubernetes
- **Istio:** Service mesh for application-layer segmentation
- **Network Policies:** Kubernetes native

---

### Network Policy Examples

**Default Deny:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Allow Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: gateway
    ports:
    - protocol: TCP
      port: 80
```

---

### SDP (Software-Defined Perimeter)

**What It Is:** "Black cloud" architecture where infrastructure is invisible until authenticated.

**Benefits:**
- Hides infrastructure from unauthorized users
- Reduces attack surface
- Enforces Zero Trust at network level

**Components:**
- SDP Controller
- SDP Gateway (Edge Router)
- SDP Client
- Identity Provider

---

### East-West Traffic Controls

**What It Is:** Traffic between internal systems

**Controls:**
- Circuit breaking
- Retry policies
- Timeouts
- Rate limiting
- Load balancing

**Blast Radius Minimization:**
- Isolate production from R&D
- Isolate OT completely
- Isolate environments (dev/stage/prod)

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

# PART 3: CLOUD-NATIVE SECURITY

---

## 3.1 Multi-Cloud Security
### Key Concepts & Takeaways

---

### Multi-Cloud Strategy

**Why Multi-Cloud:**
- Avoids vendor lock-in
- Provides cross-cloud DR
- Leverages best-of-breed services
- Meets customer requirements
- Supports business continuity

**Cloud Strategy:**

| Workload | Primary | Secondary | Strategy |
|----------|---------|-----------|----------|
| Customer Portal | AWS | Azure | Active-Active |
| Payment Services | AWS | Azure | Active-Passive |
| R&D Systems | AWS | AWS | Active-Passive |
| Financial Systems | Azure | AWS | Active-Passive |

---

### AWS Landing Zone

```
AWS Organizations
├── Security OU
│   ├── Security Account
│   └── Audit Account
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
└── Workloads OU
    ├── Production Account
    ├── R&D Account
    └── Dev/Test Account
```

**Security Controls:**
- SCPs (Service Control Policies)
- Security Hub
- GuardDuty
- Config
- CloudTrail

---

### Azure Landing Zone

```
Management Groups
├── Security
│   ├── Security Subscription
│   └── Audit Subscription
├── Infrastructure
│   ├── Network Subscription
│   └── Shared Services Subscription
└── Workloads
    ├── Production Subscription
    ├── R&D Subscription
    └── Dev/Test Subscription
```

**Security Controls:**
- Azure Policy
- Security Center (Defender for Cloud)
- Defender
- Activity Log

---

### Shared Responsibility Model

| Domain | Provider | Customer |
|--------|----------|----------|
| Physical Infrastructure | ✅ | ❌ |
| Hypervisor | ✅ | ❌ |
| Managed Services | ✅ | ❌ |
| Guest OS | ❌ | ✅ |
| Application Code | ❌ | ✅ |
| Data | ❌ | ✅ |
| IAM | ❌ | ✅ |
| Network Security | ❌ | ✅ |

---

### CSPM (Cloud Security Posture Management)

**Purpose:** Continuous cloud compliance monitoring

**AWS:** Security Hub
**Azure:** Security Center (Defender for Cloud)

**Key Controls:**
- CIS benchmarks
- NIST 800-53 controls
- Custom policies

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 3.2 Container & Kubernetes Security
### Key Concepts & Takeaways

---

### Container Security Lifecycle

| Stage | Controls | Tools |
|-------|----------|-------|
| **Build** | Image scanning, SBOM, signing | Trivy, Syft, Cosign |
| **Deploy** | Admission controllers, pod security | Kyverno, PSA |
| **Run** | Runtime monitoring, isolation | Falco, Network Policies |

---

### Container Image Security

| Control | Purpose | Tool |
|---------|---------|------|
| **Vulnerability Scanning** | Find CVEs in images | Trivy |
| **SBOM Generation** | List all components | Syft |
| **Image Signing** | Verify integrity | Cosign |

---

### Kubernetes Security

| Control | Purpose | Implementation |
|---------|---------|----------------|
| **RBAC** | Role-based access control | Roles, ClusterRoles, Bindings |
| **Admission Control** | Policy enforcement | Kyverno |
| **Pod Security** | Secure pod configurations | Pod Security Standards |
| **Network Policies** | Micro-segmentation | Calico |
| **Runtime Security** | Threat detection | Falco |

---

### Pod Security Standards

| Standard | Use Case | Restrictions |
|----------|----------|--------------|
| **Privileged** | Legacy, system | None |
| **Baseline** | Dev, R&D | Some restrictions |
| **Restricted** | Production, OT | Most restrictive |

**Restricted Requirements:**
- Run as non-root
- Read-only root filesystem
- Drop all capabilities
- No privilege escalation

---

### Kyverno Policies

**Common Policies:**
- Require image tags (no 'latest')
- Require resource limits
- Require non-root user
- Deny privilege escalation
- Deny host networking

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 3.3 Infrastructure as Code Security
### Key Concepts & Takeaways

---

### What is IaC Security?

**Infrastructure as Code (IaC) Security** is the practice of securing infrastructure defined in code.

**Key Controls:**
- Terraform scanning
- Policy-as-Code
- CI/CD security gates
- Secret management
- Compliance validation

---

### Terraform Security Scanning

| Tool | Purpose |
|------|---------|
| **Terrascan** | Vulnerability scanning |
| **Checkov** | Misconfiguration detection |
| **OPA** | Policy enforcement |

**Common Findings:**
- Public S3 buckets
- Unencrypted volumes
- Open security groups
- IAM over-privileged roles

---

### Policy-as-Code

**What It Is:** Security policies defined and enforced as code

**Tools:**
- OPA (Open Policy Agent)
- Sentinel (Terraform)
- Kyverno (Kubernetes)

**OPA Example:**
```rego
deny[msg] {
    resource := input.resource.aws_db_instance[_]
    resource.storage_encrypted == false
    msg := sprintf("RDS instance %s must have encryption enabled", [resource.name])
}
```

---

### CI/CD Security Gates

| Gate | Check | Fail Condition |
|------|-------|----------------|
| Pre-Commit | Secrets, format | Secret found |
| Build | SAST, SCA | Critical vulnerability |
| Container | Image scan | Critical vulnerability |
| Deploy | Policy check | Policy violation |

---

### Secrets Management

**Best Practices:**
- Never hardcode secrets
- Use Vault or similar
- Rotate credentials
- Audit secret access
- Use dynamic credentials

**Vault Integration:**
```hcl
data "vault_generic_secret" "aws_credentials" {
  path = "secret/data/aws/production"
}

resource "aws_db_instance" "main" {
  username = data.vault_generic_secret.aws_credentials.data["db_username"]
  password = data.vault_generic_secret.aws_credentials.data["db_password"]
}
```

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 3.4 API Security
### Key Concepts & Takeaways

---

### OWASP API Security Top 10

| Rank | Vulnerability | Description | Mitigation |
|------|---------------|-------------|------------|
| 1 | BOLA | Object-level authorization | Proper authorization checks |
| 2 | Broken Authentication | Weak auth | MFA, OIDC |
| 3 | Excessive Data Exposure | Too much data in responses | Response limiting |
| 4 | Lack of Rate Limiting | No request limits | Rate limiting, throttling |
| 5 | Broken Function Level Auth | Function access not validated | Function auth checks |
| 6 | Mass Assignment | User modifies fields they shouldn't | Schema validation |
| 7 | Security Misconfiguration | Misconfigured security | Hardening, headers |
| 8 | Injection | SQL, NoSQL, command injection | Input validation |
| 9 | Improper Asset Management | Exposed old API versions | Deprecation headers |
| 10 | Insufficient Logging | No visibility | SIEM, audit logging |

---

### API Gateway Security

**Kong Security Plugins:**
- OIDC: Authentication
- JWT: Token validation
- Rate Limiting: Request throttling
- CORS: Cross-origin protection
- OWASP: API Top 10 protections

**Rate Limiting:**
- Per-user: 100 req/min
- Per-IP: 100 req/min
- Per-API: 1000 req/min

---

### JWT Validation

**What to Validate:**
- Signature (integrity)
- Expiration (not expired)
- Audience (correct recipient)
- Issuer (trusted source)
- Claims (MFA, roles, etc.)

**JWT Security Best Practices:**
- Use short-lived tokens (15 min)
- Use RS256 or stronger
- Store securely (HTTP-only cookies)
- Validate audience and issuer
- Include MFA claim

---

### Input Validation

**What to Validate:**
- Structure (JSON schema)
- Data types
- Length limits
- Pattern matching
- SQL injection prevention
- XSS prevention

**JSON Schema Example:**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "customer_id": {
      "type": "string",
      "pattern": "^CUST-[0-9]{6}$"
    }
  },
  "required": ["customer_id"]
}
```

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 3.5 DevSecOps CI/CD
### Key Concepts & Takeaways

---

### What is DevSecOps?

**DevSecOps** = Development + Security + Operations

**Key Concept:** "Shift Left" - Move security earlier in the development process

**The DevSecOps Pipeline:**
```
Plan → Code → Build → Test → Release → Deploy → Operate
  │      │       │       │        │         │         │
  │   Security  SAST   SCA     Container  Policy    Runtime
  │   Reviews   Scans  Scans   Scans      Check    Security
```

---

### Security Testing Types

| Type | What It Does | When | Tool |
|------|--------------|------|------|
| **SAST** | Static Analysis | Code | Semgrep |
| **DAST** | Dynamic Analysis | Running | ZAP |
| **SCA** | Dependency Analysis | Build | Snyk |
| **Container** | Image Scanning | Build | Trivy |
| **IaC** | Infrastructure Scan | Deploy | Terrascan |

---

### SAST (Static Application Security Testing)

**Purpose:** Find vulnerabilities in source code

**Common Checks:**
- SQL injection patterns
- Cross-site scripting (XSS)
- Hardcoded secrets
- Insecure deserialization
- Command injection

**Semgrep Example:**
```yaml
rules:
  - id: sql-injection
    pattern: |
      query = "SELECT * FROM users WHERE id = " + user_input
    message: "SQL injection risk"
    severity: ERROR
```

---

### SCA (Software Composition Analysis)

**Purpose:** Find vulnerabilities in dependencies

**Common Issues:**
- Known CVEs in libraries
- Outdated versions
- License compliance issues

**SCA Tool Example (Snyk):**
```bash
snyk test
```

---

### Pipeline Security Gates

| Gate | Check | Fail Condition |
|------|-------|----------------|
| 1. Pre-Commit | Secrets, format | Secret found |
| 2. SAST | Code vulnerabilities | Critical/High |
| 3. SCA | Dependency vulnerabilities | Critical/High |
| 4. Container | Image vulnerabilities | Critical/High |
| 5. Policy | Compliance | Policy violation |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

# PART 4: DETECTION & RESILIENCE

---

## 4.1 SIEM/XDR Architecture
### Key Concepts & Takeaways

---

### What is SIEM?

**SIEM (Security Information and Event Management)** is a system that collects, analyzes, and reports on security data.

**Components:**
- Log ingestion
- Data storage
- Detection rules
- Alerting
- Dashboards

**ELK Stack:**
- **Elasticsearch:** Storage and indexing
- **Logstash:** Ingestion and enrichment
- **Kibana:** Visualization and dashboards

---

### SIEM Architecture

```
Data Sources
├── Application Logs
├── System Logs
├── Security Logs
├── Cloud Logs
└── XDR Telemetry
    │
    ▼
Logstash (Ingestion)
├── Parse
├── Enrich
└── Normalize
    │
    ▼
Elasticsearch (Storage)
├── Hot (90 days)
├── Warm (180 days)
├── Cold (365 days)
└── Delete (365+ days)
    │
    ▼
Kibana (Visualization)
├── Security Overview
├── Incident Response
├── Threat Hunting
└── Compliance
```

---

### Log Retention Strategy

| Tier | Storage | Purpose | Access Speed |
|------|---------|---------|--------------|
| **Hot** | Fast storage | Recent logs, fast queries | Immediate |
| **Warm** | Standard storage | Medium-term logs | Fast |
| **Cold** | Archive storage | Long-term logs | Slow |
| **Delete** | N/A | Expired logs | N/A |

---

### XDR (Extended Detection and Response)

**What It Is:** SIEM + Endpoint detection

**Key Features:**
- Endpoint telemetry
- File monitoring
- Process monitoring
- Registry monitoring
- Malware detection

**Benefits:**
- Visibility into endpoints
- Faster detection
- Better context
- Integrated response

**Example:** CrowdStrike Falcon XDR

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 4.2 Detection Engineering
### Key Concepts & Takeaways

---

### What is Detection Engineering?

**Detection engineering** is the process of creating, testing, and maintaining rules that identify security threats.

**Key Concepts:**
- Sigma rules
- MITRE ATT&CK mapping
- Rule lifecycle
- False positive management

---

### Sigma Rules

**What It Is:** Vendor-neutral detection rule format

**Structure:**
```yaml
title: "Rule Title"
id: "rule-001"
status: "production"
description: "What the rule detects"
tags:
  - attack.tXXXX
logsource:
  product: windows|linux|aws|azure
  service: service_name
detection:
  selection:
    FieldName: "Value"
  condition: selection
falsepositives:
  - "Legitimate activity"
level: high|medium|low|critical
```

---

### Rule Lifecycle

| Stage | Activity |
|-------|----------|
| 1 | Identify threat |
| 2 | Develop rule |
| 3 | Test rule |
| 4 | Deploy rule |
| 5 | Monitor alerts |
| 6 | Tune as needed |
| 7 | Review and improve |

---

### MITRE ATT&CK Mapping

| Rule | MITRE Technique | Tactic |
|------|-----------------|--------|
| Credential Dumping | T1003 | Credential Access |
| Privilege Escalation | T1068 | Privilege Escalation |
| Lateral Movement | T1021 | Lateral Movement |
| Ransomware | T1486 | Impact |

---

### False Positive Management

**What It Is:** Reducing alerts triggered by benign activity

**Approaches:**
- Tune rule thresholds
- Add filter conditions
- Create exceptions
- Use whitelists

**Metrics:**
- False Positive Rate: < 3%
- Alert Volume: < 100/day

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 4.3 Threat Hunting
### Key Concepts & Takeaways

---

### What is Threat Hunting?

**Threat hunting** is the proactive search for threats that have evaded existing detection controls.

**vs Detection:**
- **Detection:** Reactive (alerts)
- **Hunting:** Proactive (hypothesis-driven)

---

### The Hunting Process

| Stage | Activity |
|-------|----------|
| 1 | Hypothesis formulation |
| 2 | Data collection |
| 3 | Analysis & investigation |
| 4 | Discovery & validation |
| 5 | Improvement |

---

### Hypothesis Types

| Type | Description | Example |
|------|-------------|---------|
| **Intel-Based** | Driven by threat intelligence | "APT groups are targeting our industry" |
| **Data-Driven** | Driven by data analysis | "Unusual outbound connections" |
| **TTP-Based** | Driven by attacker behavior | "Credential dumping patterns" |
| **Analytics-Based** | Driven by anomalies | "User behavior anomalies" |

---

### Hunting Playbooks

**Credential Dumping Hunt:**
1. Query: LSASS access events
2. Analyze: Suspicious processes
3. Correlate: Network connections
4. Validate: Confirm findings

**Lateral Movement Hunt:**
1. Query: RDP logins
2. Analyze: Out-of-hours access
3. Correlate: External IPs
4. Validate: Account usage patterns

---

### Hunting Tools

| Tool | Purpose |
|------|---------|
| Kibana | Log query and analysis |
| Jupyter Notebooks | Interactive data analysis |
| Python | Custom analytics |
| MITRE ATT&CK Navigator | TTP mapping |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 4.4 SOAR Automation
### Key Concepts & Takeaways

---

### What is SOAR?

**SOAR (Security Orchestration, Automation, and Response)** automates incident response workflows.

**Components:**
- **Orchestration:** Connect tools
- **Automation:** Execute playbooks
- **Response:** Take actions

---

### Playbooks

**What It Is:** Automated response workflows

**Common Playbooks:**
1. Phishing Response
2. Ransomware Response
3. Compromised Credentials
4. Zero Trust Violation
5. API Abuse

**Phishing Response Playbook:**
1. Alert Triage (5 min)
2. Email Analysis (10 min)
3. User Isolation (5 min)
4. Containment (10 min)
5. User Notification (15 min)
6. Case Documentation (15 min)

---

### Automated Actions

**Common Actions:**
- Quarantine mailbox
- Disable account
- Reset password
- Revoke sessions
- Block IP
- Isolate endpoint
- Rotate credentials

---

### Case Management

**Purpose:** Track and manage incidents

**Key Fields:**
- Case ID
- Title
- Description
- Severity
- Priority
- Status
- Assignee

**SLA Policies:**
| Severity | Response Time | Resolution Time |
|----------|---------------|-----------------|
| CRITICAL | 15 min | 4 hours |
| HIGH | 30 min | 8 hours |
| MEDIUM | 1 hour | 24 hours |
| LOW | 4 hours | 48 hours |

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 4.5 Chaos Engineering
### Key Concepts & Takeaways

---

### What is Chaos Engineering?

**Chaos engineering** is the practice of intentionally injecting failures into systems to test their resilience.

**Key Concept:** Fire drills for your systems

---

### Failure Scenarios

| Scenario | Type | Frequency |
|----------|------|-----------|
| Node Failure | Infrastructure | Weekly |
| Network Partition | Network | Bi-weekly |
| DNS Failure | Infrastructure | Weekly |
| Database Failure | Database | Weekly |
| CPU Pressure | Resource | Monthly |

---

### Security Chaos Experiments

| Experiment | Purpose | Frequency |
|------------|---------|-----------|
| IAM Policy Revocation | Test access controls | Monthly |
| MFA Bypass Simulation | Test MFA enforcement | Monthly |
| Ransomware Simulation | Test detection | Quarterly |
| Zero Trust Violation | Test continuous verification | Weekly |

---

### Resilience Metrics

**Key Metrics:**
- **MTTD:** Mean Time to Detect
- **MTTR:** Mean Time to Respond
- **Recovery Rate:** % of failures that auto-recover
- **Error Rate:** % of errors during failure

---

### The Chaos Test Process

1. Define hypothesis
2. Plan test
3. Execute test
4. Analyze results
5. Improve

**Example:**
- **Hypothesis:** "The system should automatically recover from a node failure"
- **Test:** Turn off a Kubernetes node
- **Measure:** Recovery time
- **Result:** Auto-recovery < 2 minutes
- **Improvement:** Optimize pod scheduling

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

## 4.6 Business Continuity
### Key Concepts & Takeaways

---

### What is Business Continuity?

**Business Continuity** is the capability to continue operating during and after disruptive events.

**Key Concepts:**
- **BCP:** Business Continuity Plan
- **BIA:** Business Impact Analysis
- **RTO:** Recovery Time Objective
- **RPO:** Recovery Point Objective

---

### Recovery Tiers

| Tier | Description | RTO | RPO |
|------|-------------|-----|-----|
| **0** | Critical | 2 hours | 15 minutes |
| **1** | High | 4 hours | 1 hour |
| **2** | Medium | 8 hours | 4 hours |
| **3** | Low | 24 hours | 24 hours |

---

### Recovery Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Active-Active** | Multiple live sites | Customer Portal |
| **Active-Passive** | Primary + standby | Financial Systems |
| **Air-Gapped** | Offline recovery | Ransomware recovery |
| **SaaS Provider** | Provider managed | Collaboration tools |

---

### Immutable Backups

**What It Is:** Backups that cannot be modified or deleted (WORM)

**Benefits:**
- Protection from ransomware
- Compliance with regulations
- Data integrity

**AWS:** S3 Object Lock
**Azure:** Immutable Blob

---

### Air-Gapped Vaults

**What It Is:** Completely isolated storage disconnected from networks

**Access Requirements:**
- 2-person approval
- Justification required
- 12-24 hour retrieval

**Storage:**
- AWS S3 Glacier Deep Archive
- Offline tape storage

---

### Student Notes Space

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

# QUICK REFERENCE CARDS

---

## Quick Reference: SABSA

| Layer | Question | Focus |
|-------|----------|-------|
| Contextual | Why? | Business requirements |
| Conceptual | What? | Security strategy |
| Logical | How? | Security services |
| Physical | Where? | Technology |
| Component | Who/Which? | Components |
| Operational | When/Where/How? | Procedures |

---

## Quick Reference: NIST CSF 2.0

| Function | Purpose |
|----------|---------|
| Govern | Strategy and oversight |
| Identify | Assets and risks |
| Protect | Safeguards |
| Detect | Events |
| Respond | Incidents |
| Recover | Operations |

---

## Quick Reference: ISO 27001

| Component | Purpose |
|-----------|---------|
| ISMS Policy | Security commitment |
| Risk Assessment | What could go wrong? |
| Statement of Applicability | Which controls apply? |
| PDCA | Continuous improvement |

---

## Quick Reference: MITRE ATT&CK

| Tactic | Key Techniques |
|--------|----------------|
| Initial Access | T1078, T1190 |
| Privilege Escalation | T1068, T1548 |
| Lateral Movement | T1021 |
| Credential Access | T1003 |
| Exfiltration | T1041 |
| Impact | T1486 |

---

## Quick Reference: Zero Trust Principles

1. **Verify Explicitly** - Always authenticate and authorize
2. **Least Privilege** - Minimum access needed
3. **Assume Breach** - Design for detection

---

## Quick Reference: OWASP API Top 10

1. BOLA
2. Broken Authentication
3. Excessive Data Exposure
4. Rate Limiting
5. Function Level Auth
6. Mass Assignment
7. Misconfiguration
8. Injection
9. Asset Management
10. Logging & Monitoring

---

## Quick Reference: Metrics

| Metric | Target |
|--------|--------|
| MTTD | < 60 minutes |
| MTTR | < 4 hours |
| False Positive Rate | < 3% |
| MFA Coverage | 100% |
| Zero Trust Coverage | 100% |
| RTO (Tier 0) | < 2 hours |
| RPO (Tier 0) | < 15 minutes |

---

**[END OF STUDENT NOTES]**

---

## How to Use These Notes Effectively

1. **Preview Before Class:** Read the notes before each session to familiarize yourself with key concepts

2. **Take Additional Notes:** Use the blank spaces to add your own notes, examples, and questions

3. **Review After Class:** Review the notes and complete any incomplete sections

4. **Connect Concepts:** Look for connections between sections and parts

5. **Test Yourself:** Use the quiz bank to test your knowledge

6. **Reference During Exercises:** Use these notes as a reference during hands-on exercises

7. **Create Your Own Summary:** Create your own summary or mind map of the key concepts
