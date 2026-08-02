# Enterprise Cybersecurity Architecture & Frameworks
## Complete Student Workbook
### Hands-On Exercises & Guided Practice

## About This Workbook

This workbook contains hands-on exercises for each section of the 5-part series. Each exercise includes:

- **Learning Objectives** - What you'll learn
- **Prerequisites** - What you need before starting
- **Step-by-Step Instructions** - Guided practice
- **Verification Steps** - Confirm your work is correct
- **Reflection Questions** - Deepen your understanding
- **Challenge Exercises** - Extend your learning

**Total Exercises:** 45
**Estimated Time:** 90+ hours

---

# PART 1: FOUNDATIONS & FRAMEWORKS
## Section 1.1: SABSA Framework

---

### Exercise 1.1.1: Business Context Analysis

**Learning Objective:** Analyze business requirements and translate them into security attributes.

**Prerequisites:** Understanding of basic business concepts

**Duration:** 45 minutes

---

#### Scenario

Nexus Global Industries is expanding into a new market. They are launching a new digital twin platform that will connect manufacturing facilities globally. The platform will collect real-time production data, AI/ML analytics, and customer order information.

**Business Requirements:**
1. The platform must be available 24/7 globally
2. Customer order data is highly sensitive (PII + manufacturing specifications)
3. AI/ML models are the company's core intellectual property
4. The platform must integrate with existing OT systems
5. Regulatory compliance: GDPR, NIST 800-171, local manufacturing regulations

---

#### Exercise Instructions

**Step 1: Identify Critical Assets**

List the critical assets in this scenario:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Define Security Attributes**

For each asset, define the required security attributes (Confidentiality, Integrity, Availability):

| Asset | Confidentiality | Integrity | Availability | Rationale |
|-------|-----------------|-----------|--------------|-----------|
| Customer Order Data | | | | |
| AI/ML Models | | | | |
| Real-time Production Data | | | | |
| OT Systems | | | | |

**Step 3: Create a SABSA Contextual Diagram**

Draw a diagram showing:
- Business drivers → Critical assets → Security attributes → Risk environment

(Use the space below or use a diagramming tool)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Step 4: Draft a Risk Appetite Statement**

Write a risk appetite statement for the digital twin platform:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm all critical assets are identified
✅ Confirm all assets have defined security attributes
✅ Confirm risk appetite statement is clear and actionable

---

#### Reflection Questions

1. How does business strategy drive security requirements?

________________________________________________________________________________
________________________________________________________________________________

2. What trade-offs exist between security attributes?

________________________________________________________________________________
________________________________________________________________________________

3. How would you prioritize security investments for this platform?

________________________________________________________________________________
________________________________________________________________________________

---

#### Challenge Exercise

Create a SABSA conceptual architecture outline for the digital twin platform, identifying the key security services required.

**Security Services Required:**

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

---

### Exercise 1.1.2: SABSA Traceability Matrix

**Learning Objective:** Create a traceability matrix connecting business requirements to operational procedures.

**Prerequisites:** Exercise 1.1.1

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define Business Requirements**

Using the digital twin platform scenario, list 5 business requirements:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Map to Security Services**

For each business requirement, identify the security services needed:

| Business Requirement | Security Service | Rationale |
|---------------------|------------------|-----------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 3: Map to Security Mechanisms**

For each security service, identify the mechanism:

| Security Service | Security Mechanism | How It Works |
|------------------|-------------------|--------------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 4: Map to Technology**

For each mechanism, identify the technology:

| Security Mechanism | Technology | Why This Technology |
|-------------------|------------|---------------------|
| | | |
| | | |
| | | |
| | | |

**Step 5: Map to Operational Procedure**

For each technology, identify the operational procedure:

| Technology | Operational Procedure | Frequency |
|------------|----------------------|-----------|
| | | |
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm traceability from business requirements to operations
✅ Confirm each layer is complete
✅ Confirm all entries are consistent

---

#### Reflection Questions

1. Why is traceability important in security architecture?

________________________________________________________________________________
________________________________________________________________________________

2. What happens when traceability is broken?

________________________________________________________________________________
________________________________________________________________________________

3. How does the SABSA traceability matrix support audit and compliance?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 1.2: NIST CSF 2.0

### Exercise 1.2.1: CSF Function Mapping

**Learning Objective:** Map organizational security activities to NIST CSF 2.0 functions.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Review CSF Functions**

List the six NIST CSF 2.0 functions and their purposes:

| Function | Purpose |
|----------|---------|
| 1. | |
| 2. | |
| 3. | |
| 4. | |
| 5. | |
| 6. | |

**Step 2: Map Activities to Functions**

For each security activity, identify which CSF function it belongs to:

| Activity | CSF Function | Justification |
|----------|--------------|---------------|
| Conducting phishing simulations | | |
| Creating an incident response plan | | |
| Implementing MFA for all users | | |
| Performing a risk assessment | | |
| Testing disaster recovery procedures | | |
| Reviewing security policies | | |
| Monitoring network traffic for anomalies | | |
| Installing endpoint protection software | | |
| Conducting security awareness training | | |
| Restoring systems after a ransomware attack | | |

**Step 3: Identify Gaps**

List security activities that are NOT currently being performed:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Step 4: Prioritize Gaps**

For each gap, assess its priority:

| Gap | Priority (High/Medium/Low) | Why? |
|-----|---------------------------|------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm all activities are correctly mapped
✅ Confirm gaps are identified
✅ Confirm priorities are justified

---

#### Reflection Questions

1. Which CSF function do you think is most critical? Why?

________________________________________________________________________________
________________________________________________________________________________

2. How does the Govern function change the way organizations approach cybersecurity?

________________________________________________________________________________
________________________________________________________________________________

3. Which CSF function is most challenging to implement? Why?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 1.2.2: CSF Implementation Tiers Assessment

**Learning Objective:** Assess organizational cybersecurity maturity using CSF Implementation Tiers.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Review CSF Tiers**

Describe each CSF Implementation Tier:

| Tier | Name | Description |
|------|------|-------------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |

**Step 2: Self-Assessment**

Assess your organization (or a hypothetical organization) against each CSF function:

| Function | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Evidence |
|----------|--------|--------|--------|--------|----------|
| Govern | ☐ | ☐ | ☐ | ☐ | |
| Identify | ☐ | ☐ | ☐ | ☐ | |
| Protect | ☐ | ☐ | ☐ | ☐ | |
| Detect | ☐ | ☐ | ☐ | ☐ | |
| Respond | ☐ | ☐ | ☐ | ☐ | |
| Recover | ☐ | ☐ | ☐ | ☐ | |

**Step 3: Create Improvement Plan**

Based on the self-assessment, create a plan to improve to the next tier:

| Function | Current Tier | Target Tier | Actions Required | Timeline |
|----------|--------------|-------------|------------------|----------|
| Govern | | | | |
| Identify | | | | |
| Protect | | | | |
| Detect | | | | |
| Respond | | | | |
| Recover | | | | |

---

#### Verification

✅ Confirm self-assessment is complete
✅ Confirm improvement plan is actionable
✅ Confirm timelines are realistic

---

#### Reflection Questions

1. What is the value of assessing cybersecurity maturity?

________________________________________________________________________________
________________________________________________________________________________

2. What are the challenges of moving from Tier 1 to Tier 2?

________________________________________________________________________________
________________________________________________________________________________

3. How does Tier 4 (Adaptive) differ from Tier 3 (Repeatable)?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 1.3: ISO 27001 ISMS

### Exercise 1.3.1: Risk Assessment

**Learning Objective:** Perform a risk assessment using ISO 27001 methodology.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Identify Assets**

List 5 critical information assets:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Identify Threats**

For each asset, identify potential threats:

| Asset | Threats |
|-------|---------|
| | |
| | |
| | |
| | |
| | |

**Step 3: Assess Likelihood and Impact**

Score each risk (Likelihood: 1-5, Impact: 1-5):

| Asset | Threat | Likelihood | Impact | Score | Risk Level |
|-------|--------|------------|--------|-------|------------|
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |

**Step 4: Determine Risk Treatment**

For each risk, determine the treatment option:

| Risk | Treatment Option | Justification |
|------|------------------|---------------|
| | | |
| | | |
| | | |
| | | |

**Step 5: Create a Risk Treatment Plan**

Document the plan for each high-risk item:

| Risk | Control | Owner | Timeline |
|------|---------|-------|----------|
| | | | |
| | | | |
| | | | |

---

#### Verification

✅ Confirm all assets are identified
✅ Confirm risks are scored correctly
✅ Confirm treatment plans are documented

---

#### Reflection Questions

1. What are the challenges of risk assessment?

________________________________________________________________________________
________________________________________________________________________________

2. How does risk assessment drive security investment decisions?

________________________________________________________________________________
________________________________________________________________________________

3. How often should risk assessments be performed?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 1.3.2: Statement of Applicability

**Learning Objective:** Create a Statement of Applicability (SoA) for ISO 27001.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Identify Applicable Controls**

Review Annex A control categories:

| Category | # of Controls | Examples |
|----------|---------------|----------|
| A.5 Organizational | | |
| A.6 People | | |
| A.7 Physical | | |
| A.8 Technology | | |

**Step 2: Justify Applicability**

For each control category, justify why it applies to your organization:

| Control Category | Applicable? (Yes/No) | Justification |
|------------------|---------------------|---------------|
| A.5 Organizational | | |
| A.6 People | | |
| A.7 Physical | | |
| A.8 Technology | | |

**Step 3: Select Key Controls**

Select 10 key controls that are essential for your organization:

| Control ID | Control Name | Why Selected | Implementation Status |
|------------|--------------|--------------|----------------------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

**Step 4: Document Exclusions**

Identify controls that are NOT applicable and explain why:

| Control ID | Control Name | Why Not Applicable |
|------------|--------------|-------------------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm SoA is complete
✅ Confirm all exclusions are justified
✅ Confirm all selected controls have implementation status

---

#### Reflection Questions

1. What is the purpose of the Statement of Applicability?

________________________________________________________________________________
________________________________________________________________________________

2. How do you justify excluding a control?

________________________________________________________________________________
________________________________________________________________________________

3. How does the SoA support continuous improvement?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 1.4: Threat Modeling

### Exercise 1.4.1: STRIDE Analysis

**Learning Objective:** Perform a STRIDE analysis on a system component.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Select a Component**

Choose a system component to analyze (e.g., API Gateway, Authentication Service, Database):

Component: _________________________________________________

**Step 2: Document Component Details**

- **Purpose:** _________________________________________________
- **Inputs:** _________________________________________________
- **Outputs:** _________________________________________________
- **Trust Boundaries:** _________________________________________________

**Step 3: Perform STRIDE Analysis**

| Threat Category | Potential Threat | Impact | Likelihood | Mitigation |
|-----------------|------------------|--------|------------|------------|
| **S**poofing | | | | |
| **T**ampering | | | | |
| **R**epudiation | | | | |
| **I**nfo Disclosure | | | | |
| **D**oS | | | | |
| **E**levation | | | | |

**Step 4: Prioritize Threats**

Rank the top 5 threats:

| Rank | Threat | Risk Level | Priority |
|------|--------|------------|----------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

**Step 5: Create Mitigation Plan**

For the top 3 threats, document a mitigation plan:

| Threat | Mitigation | Owner | Timeline |
|--------|------------|-------|----------|
| | | | |
| | | | |
| | | | |

---

#### Verification

✅ Confirm all threat categories are addressed
✅ Confirm mitigations are documented
✅ Confirm plan is actionable

---

#### Reflection Questions

1. Which STRIDE category do you find most challenging to identify?

________________________________________________________________________________
________________________________________________________________________________

2. How does STRIDE complement other threat modeling methodologies?

________________________________________________________________________________
________________________________________________________________________________

3. How often should you review and update threat models?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 1.4.2: Attack Tree Creation

**Learning Objective:** Create an attack tree for a high-priority threat.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Select a Scenario**

Choose an attack scenario (e.g., Ransomware, Data Breach, IP Theft):

Scenario: _________________________________________________

**Step 2: Define the Root Goal**

Attacker's ultimate goal: _________________________________________________

**Step 3: Identify Sub-Goals**

List the major steps needed to achieve the root goal:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________

**Step 4: Create the Attack Tree**

Draw an attack tree with OR and AND nodes:

```
                    [Root Goal]
                        /     \
                   [Sub1]     [Sub2]
                   /    \     /    \
              [Leaf1] [Leaf2] [Leaf3] [Leaf4]
```

(Use the space below to draw your attack tree)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Step 5: Identify Controls**

For each leaf node, identify a control that prevents or detects it:

| Leaf Node | Control | Type (Prevent/Detect) |
|-----------|---------|----------------------|
| | | |
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm attack tree is complete
✅ Confirm all controls are identified
✅ Confirm tree accurately represents the attack path

---

#### Reflection Questions

1. What are the benefits of visualizing attacks as trees?

________________________________________________________________________________
________________________________________________________________________________

2. How can attack trees be used to prioritize security controls?

________________________________________________________________________________
________________________________________________________________________________

3. How do attack trees complement other threat modeling approaches?

________________________________________________________________________________
________________________________________________________________________________

---

# PART 2: ZERO TRUST & IDENTITY
## Section 2.1: Zero Trust Architecture

### Exercise 2.1.1: Zero Trust Principles Application

**Learning Objective:** Apply Zero Trust principles to a real-world scenario.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Scenario:** A manufacturing company has a remote workforce accessing the corporate network via VPN. Employees use laptops, tablets, and some personal devices. The company stores sensitive customer data in the cloud.

**Step 1: Identify Traditional Security Gaps**

List the security issues with the current approach:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Apply Zero Trust Principles**

For each of the three Zero Trust principles, describe how to apply them:

| Principle | Application |
|-----------|-------------|
| Verify Explicitly | |
| Least Privilege | |
| Assume Breach | |

**Step 3: Design Zero Trust Controls**

Design controls for each of the Zero Trust pillars:

| Pillar | Control | How It Implements Zero Trust |
|--------|---------|------------------------------|
| Identity | | |
| Devices | | |
| Networks | | |
| Applications | | |
| Data | | |

**Step 4: Identify Changes Required**

List the changes required to implement Zero Trust:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

---

#### Verification

✅ Confirm all principles are applied
✅ Confirm controls are designed
✅ Confirm changes are identified

---

#### Reflection Questions

1. What is the biggest challenge in implementing Zero Trust?

________________________________________________________________________________
________________________________________________________________________________

2. How does Zero Trust change the user experience?

________________________________________________________________________________
________________________________________________________________________________

3. What is the role of MFA in Zero Trust?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 2.1.2: OPA Policy Writing

**Learning Objective:** Write a Rego policy for OPA.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define the Policy Requirement**

Write a policy statement:

"________________________________________________________________________________"

**Step 2: Identify Inputs**

List the inputs needed for the policy decision:

| Input | Description |
|-------|-------------|
| | |
| | |
| | |

**Step 3: Write the Policy**

Write the Rego policy:

```rego
package example.policy

# Default deny
default allow = false

# Your policy logic
allow = true {
    # Condition 1
    # Condition 2
    # Condition 3
}
```

**Step 4: Test the Policy**

Test with sample inputs:

| Test Case | Input | Expected | Actual |
|-----------|-------|----------|--------|
| Positive | | True | |
| Negative | | False | |
| Edge Case | | False | |

**Step 5: Document the Policy**

Document the policy purpose and logic:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm policy is syntactically correct
✅ Confirm policy logic is accurate
✅ Confirm tests pass

---

#### Reflection Questions

1. What are the challenges of writing Rego policies?

________________________________________________________________________________
________________________________________________________________________________

2. How do you test policies effectively?

________________________________________________________________________________
________________________________________________________________________________

3. How do you manage policy changes?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 2.1.3: Continuous Verification Design

**Learning Objective:** Design a continuous verification service.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define Verification Checks**

List the checks that should be performed continuously:

| Check | Frequency | How It Works |
|-------|-----------|--------------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 2: Define Risk Scoring**

Define a risk scoring model:

| Factor | Weight | Scoring | Max Score |
|--------|--------|---------|-----------|
| Session Age | | | |
| Idle Time | | | |
| Device Posture | | | |
| Geolocation | | | |
| Behavior | | | |

**Step 3: Define Risk Levels**

Define risk levels and actions:

| Risk Score | Level | Action |
|------------|-------|--------|
| 0-30 | | |
| 31-60 | | |
| 61-80 | | |
| 81-100 | | |

**Step 4: Design the Verification Flow**

Draw the verification flow:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Step 5: Define Metrics**

Define metrics to measure verification effectiveness:

| Metric | Target | Measurement |
|--------|--------|-------------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm checks are defined
✅ Confirm risk scoring is defined
✅ Confirm flow is designed

---

#### Reflection Questions

1. How often should verification occur?

________________________________________________________________________________
________________________________________________________________________________

2. What happens when verification fails?

________________________________________________________________________________
________________________________________________________________________________

3. How do you balance security with user experience?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 2.2: Identity & Access Management

### Exercise 2.2.1: Keycloak Configuration

**Learning Objective:** Configure a Keycloak realm with users, groups, and MFA.

**Prerequisites:** Access to a Keycloak instance or Docker

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Create a Realm**

```bash
# Docker command to start Keycloak
docker run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:23.0.7 start-dev
```

What is the admin URL? _________________________________________________

**Step 2: Create Realm**

Realm Name: _________________________________________________

**Step 3: Create Users**

Create 3 users with different roles:

| Username | Email | First Name | Last Name |
|----------|-------|------------|-----------|
| | | | |
| | | | |
| | | | |

**Step 4: Create Groups**

Create 3 groups:

| Group Name | Description |
|------------|-------------|
| | |
| | |
| | |

**Step 5: Create Roles**

Create 3 roles:

| Role Name | Description |
|-----------|-------------|
| | |
| | |
| | |

**Step 6: Configure MFA**

Document the MFA configuration steps:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 7: Configure Client**

Create a client for an application:

| Setting | Value |
|---------|-------|
| Client ID | |
| Name | |
| Protocol | |
| Access Type | |
| Valid Redirect URIs | |

---

#### Verification

✅ Confirm realm is created
✅ Confirm users can log in
✅ Confirm MFA works
✅ Confirm client is configured

---

#### Reflection Questions

1. What are the challenges of managing multiple realms?

________________________________________________________________________________
________________________________________________________________________________

2. How do you handle user lifecycle management?

________________________________________________________________________________
________________________________________________________________________________

3. What is the role of clients in Keycloak?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 2.2.2: SCIM Automation Design

**Learning Objective:** Design a SCIM 2.0 automation for JML.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define JML Workflows**

Document the JML workflows:

**Joiner (New Employee):**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Mover (Role Change):**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Leaver (Departing Employee):**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Define SCIM Endpoints**

List the SCIM endpoints needed:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /Users | POST | |
| /Users/{id} | PUT | |
| /Users/{id} | DELETE | |
| /Groups | POST | |
| /Groups/{id} | PUT | |
| /Groups/{id} | DELETE | |

**Step 3: Define User Schema**

Define the SCIM user schema:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| userName | | | |
| name | | | |
| emails | | | |
| groups | | | |
| roles | | | |
| active | | | |

**Step 4: Define Integration with HRIS**

Describe how SCIM integrates with HRIS:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 5: Define Audit Requirements**

List the audit requirements for JML:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

---

#### Verification

✅ Confirm workflows are defined
✅ Confirm endpoints are identified
✅ Confirm schema is complete

---

#### Reflection Questions

1. What are the benefits of automated JML?

________________________________________________________________________________
________________________________________________________________________________

2. What are the risks of automated JML?

________________________________________________________________________________
________________________________________________________________________________

3. How do you handle exceptions in the JML process?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 2.3: Privileged Access Management

### Exercise 2.3.1: Vault Setup

**Learning Objective:** Set up HashiCorp Vault with basic configurations.

**Prerequisites:** Docker or Vault binary

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Start Vault**

```bash
# Docker command
docker run -d --name vault \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=root \
  hashicorp/vault:1.15.6
```

Vault URL: _________________________________________________

**Step 2: Initialize Vault**

```bash
docker exec -it vault vault operator init -format=json > vault-keys.json
```

Record the unseal keys and root token:

- Unseal Key 1: _________________________________________________
- Unseal Key 2: _________________________________________________
- Unseal Key 3: _________________________________________________
- Unseal Key 4: _________________________________________________
- Unseal Key 5: _________________________________________________
- Root Token: _________________________________________________

**Step 3: Unseal Vault**

```bash
docker exec -it vault vault operator unseal <key1>
docker exec -it vault vault operator unseal <key2>
docker exec -it vault vault operator unseal <key3>
```

Verify unsealed status: _________________________________________________

**Step 4: Enable Secrets Engine**

```bash
docker exec -it vault vault secrets enable -path=secret kv-v2
```

Document the command: _________________________________________________

**Step 5: Store a Secret**

```bash
docker exec -it vault vault kv put secret/test key=value
```

Verify the secret is stored: _________________________________________________

**Step 6: Create a Policy**

Create a policy file `readonly.hcl`:

```
path "secret/*" {
  capabilities = ["read", "list"]
}
```

Apply the policy:

```bash
docker exec -it vault vault policy write readonly /path/to/readonly.hcl
```

**Step 7: Create a Token with the Policy**

```bash
docker exec -it vault vault token create -policy=readonly
```

Record the token: _________________________________________________

---

#### Verification

✅ Confirm Vault is running
✅ Confirm Vault is unsealed
✅ Confirm secrets can be stored and retrieved
✅ Confirm policies work

---

#### Reflection Questions

1. Why is Vault sealed initially?

________________________________________________________________________________
________________________________________________________________________________

2. What is the purpose of unseal keys?

________________________________________________________________________________
________________________________________________________________________________

3. How do you secure the root token?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 2.3.2: JIT Access Workflow

**Learning Objective:** Design a JIT (Just-In-Time) access workflow.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define JIT Access Request**

Document what information is needed for a JIT access request:

| Field | Required | Description |
|-------|----------|-------------|
| | | |
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 2: Define Approval Workflow**

Document the approval workflow steps:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 3: Define Session Parameters**

Define session parameters:

| Parameter | Value | Description |
|-----------|-------|-------------|
| Max Session Duration | | |
| Idle Timeout | | |
| Approvals Required | | |
| Justification Required | | |

**Step 4: Define Actions**

Define what actions should be taken when a JIT session is:

**Approved:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Denied:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Expired:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Step 5: Design the Workflow**

Draw the JIT access workflow:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

#### Verification

✅ Confirm workflow is designed
✅ Confirm session parameters are defined
✅ Confirm actions are documented

---

#### Reflection Questions

1. How do you balance security with operational needs in JIT?

________________________________________________________________________________
________________________________________________________________________________

2. What happens if approvers are unavailable?

________________________________________________________________________________
________________________________________________________________________________

3. How do you audit JIT access?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 2.4: Micro-segmentation & SDP

### Exercise 2.4.1: Kubernetes Network Policy Design

**Learning Objective:** Design Kubernetes network policies for micro-segmentation.

**Prerequisites:** Basic Kubernetes knowledge

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define Namespaces**

List the namespaces in the environment:

| Namespace | Purpose | Sensitivity |
|-----------|---------|-------------|
| | | |
| | | |
| | | |
| | | |

**Step 2: Define Default Policies**

Write a default deny policy for a namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Step 3: Define Allow Policies**

Write policies to allow specific traffic:

**Allow Ingress from API Gateway:**

```yaml

```

**Allow Internal Service Communication:**

```yaml

```

**Allow Database Access:**

```yaml

```

**Step 4: Define Isolation Policies**

Write policies to isolate sensitive namespaces:

**Isolate R&D Namespace:**

```yaml

```

**Isolate OT Namespace:**

```yaml

```

**Step 5: Document the Policy Matrix**

Create a matrix of allowed traffic:

| Source → Destination | Gateway | Payment | Database | External |
|----------------------|---------|---------|----------|----------|
| Gateway | | | | |
| Payment | | | | |
| Database | | | | |

---

#### Verification

✅ Confirm all policies are defined
✅ Confirm default deny exists
✅ Confirm minimal required access is allowed

---

#### Reflection Questions

1. What are the challenges of implementing network policies?

________________________________________________________________________________
________________________________________________________________________________

2. How do you test network policies before deployment?

________________________________________________________________________________
________________________________________________________________________________

3. What is the impact of network policies on performance?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 2.4.2: SDP Architecture Design

**Learning Objective:** Design a Software-Defined Perimeter architecture.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define SDP Components**

List the SDP components and their purpose:

| Component | Purpose |
|-----------|---------|
| Controller | |
| Gateway | |
| Client | |
| Identity Provider | |

**Step 2: Define Services to Protect**

List the services that will be protected by SDP:

| Service | Sensitivity | Why Protect |
|---------|-------------|-------------|
| | | |
| | | |
| | | |
| | | |

**Step 3: Define Access Policies**

Define who can access each service:

| Service | Who Can Access | Conditions |
|---------|---------------|------------|
| | | |
| | | |
| | | |

**Step 4: Design the Architecture**

Draw the SDP architecture:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Step 5: Define Integration Points**

List integration points with other systems:

| System | Integration | Purpose |
|--------|--------------|---------|
| Identity Provider | | |
| SIEM | | |
| Service Mesh | | |
| API Gateway | | |

---

#### Verification

✅ Confirm all components are defined
✅ Confirm services are identified
✅ Confirm access policies are defined

---

#### Reflection Questions

1. How does SDP differ from traditional VPN?

________________________________________________________________________________
________________________________________________________________________________

2. What are the benefits of the "black cloud" approach?

________________________________________________________________________________
________________________________________________________________________________

3. What are the challenges of implementing SDP?

________________________________________________________________________________
________________________________________________________________________________

---

# PART 3: CLOUD-NATIVE SECURITY
## Section 3.1: Multi-Cloud Security

### Exercise 3.1.1: Multi-Cloud Architecture Design

**Learning Objective:** Design a multi-cloud security architecture.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define Cloud Strategy**

Define which workloads will go to which cloud:

| Workload | Primary Cloud | Secondary Cloud | Why |
|----------|---------------|-----------------|-----|
| Customer Portal | | | |
| Payment Processing | | | |
| R&D Systems | | | |
| Financial Systems | | | |
| Manufacturing OT | | | |

**Step 2: Define Landing Zones**

Document the landing zone structure:

**AWS:**

```
AWS Landing Zone
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

**Azure:**

```
Azure Landing Zone
├── Security Group
│   ├── Security Subscription
│   └── Audit Subscription
├── Infrastructure Group
│   ├── Network Subscription
│   └── Shared Services Subscription
└── Workloads Group
    ├── Production Subscription
    ├── R&D Subscription
    └── Dev/Test Subscription
```

**Step 3: Define Security Controls**

List the security controls that should be consistent across clouds:

| Control | AWS Implementation | Azure Implementation |
|---------|-------------------|---------------------|
| Identity | | |
| Encryption | | |
| Monitoring | | |
| Compliance | | |
| Network Security | | |

**Step 4: Define Cross-Cloud IAM**

Describe how identity will work across clouds:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 5: Define Compliance Strategy**

Describe how compliance will be managed across clouds:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm cloud strategy is defined
✅ Confirm landing zones are designed
✅ Confirm controls are consistent

---

#### Reflection Questions

1. What are the benefits of multi-cloud?

________________________________________________________________________________
________________________________________________________________________________

2. What are the challenges of multi-cloud?

________________________________________________________________________________
________________________________________________________________________________

3. How do you ensure consistent security across clouds?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 3.1.2: CSPM Configuration

**Learning Objective:** Configure CSPM for multi-cloud environments.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define CSPM Requirements**

List the compliance standards that must be monitored:

| Standard | Description | Applicable Clouds |
|----------|-------------|-------------------|
| | | |
| | | |
| | | |

**Step 2: Define AWS Security Hub Configuration**

| Setting | Value |
|---------|-------|
| Regions Enabled | |
| Standards Enabled | |
| Controls Enabled | |
| Findings Export | |

**Step 3: Define Azure Security Center Configuration**

| Setting | Value |
|---------|-------|
| Pricing Tier | |
| Policies Enabled | |
| Assessments | |
| Recommendations | |

**Step 4: Define Automated Remediations**

Document automated remediation actions:

| Finding | Remediation Action | Tool |
|---------|-------------------|------|
| | | |
| | | |
| | | |

**Step 5: Define Reporting**

Define reporting requirements:

| Report | Frequency | Audience |
|--------|-----------|----------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm requirements are defined
✅ Confirm configurations are documented
✅ Confirm reporting is defined

---

#### Reflection Questions

1. What are the most common CSPM findings?

________________________________________________________________________________
________________________________________________________________________________

2. How do you prioritize remediation?

________________________________________________________________________________
________________________________________________________________________________

3. What is the role of automation in CSPM?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 3.2: Container & Kubernetes Security

### Exercise 3.2.1: Container Image Security

**Learning Objective:** Implement container image security controls.

**Prerequisites:** Docker, Trivy

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Create a Sample Application**

Create a simple application with vulnerabilities:

```dockerfile
# Dockerfile
FROM python:3.9-slim
COPY app.py /app/
WORKDIR /app
RUN pip install flask==1.1.2
CMD ["python", "app.py"]
```

```python
# app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, World!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**Step 2: Build the Image**

```bash
docker build -t sample-app:latest .
```

**Step 3: Scan with Trivy**

```bash
trivy image sample-app:latest
```

Record the findings:

- Critical vulnerabilities: _________________________________________________
- High vulnerabilities: _________________________________________________
- Medium vulnerabilities: _________________________________________________
- Low vulnerabilities: _________________________________________________

**Step 4: Generate SBOM**

```bash
syft sample-app:latest -o cyclonedx-json > sbom.json
```

What components are in the SBOM?

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________

**Step 5: Fix Vulnerabilities**

Update the Dockerfile to fix vulnerabilities:

```dockerfile
# Updated Dockerfile

```

**Step 6: Rebuild and Rescan**

```bash
docker build -t sample-app:fixed .
trivy image sample-app:fixed
```

Compare results:

| Severity | Before | After |
|----------|--------|-------|
| Critical | | |
| High | | |
| Medium | | |
| Low | | |

---

#### Verification

✅ Confirm image is scanned
✅ Confirm SBOM is generated
✅ Confirm vulnerabilities are fixed

---

#### Reflection Questions

1. What is the most common source of container vulnerabilities?

________________________________________________________________________________
________________________________________________________________________________

2. How do you prioritize vulnerability remediation?

________________________________________________________________________________
________________________________________________________________________________

3. What is the value of SBOM?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 3.2.2: Kyverno Policy Creation

**Learning Objective:** Create and test Kyverno policies.

**Prerequisites:** Kubernetes cluster with Kyverno

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Create a Policy**

Create a policy that requires non-root user:

```yaml

```

**Step 2: Create a Policy Requiring Resource Limits:**

```yaml

```

**Step 3: Create a Policy Denying Privilege Escalation:**

```yaml

```

**Step 4: Apply the Policies**

```bash
kubectl apply -f policies.yaml
```

**Step 5: Test the Policies**

Create a pod that violates the policy:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: bad-container
    image: nginx
    securityContext:
      runAsNonRoot: false
      allowPrivilegeEscalation: true
```

Test the pod:

```bash
kubectl apply -f bad-pod.yaml
```

What happens? _________________________________________________

**Step 6: Test with a Compliant Pod**

Create a compliant pod:

```yaml

```

Test the pod:

```bash
kubectl apply -f good-pod.yaml
```

What happens? _________________________________________________

---

#### Verification

✅ Confirm policies are applied
✅ Confirm violations are blocked
✅ Confirm compliant pods pass

---

#### Reflection Questions

1. What are the most important Kyverno policies for security?

________________________________________________________________________________
________________________________________________________________________________

2. How do you handle policy exceptions?

________________________________________________________________________________
________________________________________________________________________________

3. How do you test policies before deployment?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 3.3: Infrastructure as Code Security

### Exercise 3.3.1: Terraform Security Scanning

**Learning Objective:** Scan Terraform code for security issues.

**Prerequisites:** Terraform, Terrascan

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Create a Terraform Configuration**

Create `main.tf`:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "public-read"
}

resource "aws_db_instance" "example" {
  engine         = "mysql"
  instance_class = "db.t3.micro"
  publicly_accessible = true
}
```

**Step 2: Scan with Terrascan**

```bash
terrascan scan -i terraform -d .
```

Record the findings:

- Critical: _________________________________________________
- High: _________________________________________________
- Medium: _________________________________________________
- Low: _________________________________________________

**Step 3: Fix the Issues**

Update the Terraform configuration:

```hcl

```

**Step 4: Rescan**

```bash
terrascan scan -i terraform -d .
```

Compare results:

| Severity | Before | After |
|----------|--------|-------|
| Critical | | |
| High | | |
| Medium | | |
| Low | | |

**Step 5: Add a Policy**

Add a policy to enforce encryption:

```rego

```

---

#### Verification

✅ Confirm Terraform code is scanned
✅ Confirm issues are fixed
✅ Confirm policy is added

---

#### Reflection Questions

1. What are the most common IaC security issues?

________________________________________________________________________________
________________________________________________________________________________

2. How do you integrate scanning into CI/CD?

________________________________________________________________________________
________________________________________________________________________________

3. What is the role of Policy-as-Code in IaC security?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 3.3.2: CI/CD Security Pipeline

**Learning Objective:** Design a secure CI/CD pipeline.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define Pipeline Stages**

List the pipeline stages:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________
6. _________________________________________________

**Step 2: Define Security Gates**

For each stage, define the security checks:

| Stage | Security Check | Fail Condition |
|-------|---------------|----------------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 3: Define Pipeline Configuration**

Write the pipeline configuration:

```yaml

```

**Step 4: Define Secret Management**

Describe how secrets will be managed:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 5: Define Monitoring**

Describe how the pipeline will be monitored:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm stages are defined
✅ Confirm security gates are defined
✅ Confirm pipeline is designed

---

#### Reflection Questions

1. What are the most critical security gates?

________________________________________________________________________________
________________________________________________________________________________

2. How do you balance security with speed?

________________________________________________________________________________
________________________________________________________________________________

3. What happens when a security gate fails?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 3.4: API Security

### Exercise 3.4.1: API Threat Modeling

**Learning Objective:** Identify API security threats using OWASP API Top 10.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define the API**

Describe the API to be modeled:

- **Name:** _________________________________________________
- **Purpose:** _________________________________________________
- **Endpoints:** _________________________________________________
- **Authentication:** _________________________________________________
- **Data Handled:** _________________________________________________

**Step 2: Identify Threats**

Map each OWASP API Top 10 vulnerability to a specific threat:

| OWASP API Vulnerability | Threat in Your API | Risk Level |
|-------------------------|-------------------|------------|
| 1. BOLA | | |
| 2. Broken Authentication | | |
| 3. Excessive Data Exposure | | |
| 4. Rate Limiting | | |
| 5. Function Level Auth | | |
| 6. Mass Assignment | | |
| 7. Misconfiguration | | |
| 8. Injection | | |
| 9. Asset Management | | |
| 10. Logging & Monitoring | | |

**Step 3: Define Mitigations**

For the top 5 threats, define mitigations:

| Threat | Mitigation | Owner |
|--------|------------|-------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 4: Define Testing**

Define how each threat will be tested:

| Threat | Testing Method | Tools |
|--------|----------------|-------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm all threats are identified
✅ Confirm mitigations are documented
✅ Confirm testing is defined

---

#### Reflection Questions

1. What is the most common API vulnerability in practice?

________________________________________________________________________________
________________________________________________________________________________

2. How do you prioritize API security fixes?

________________________________________________________________________________
________________________________________________________________________________

3. How do you test for BOLA vulnerabilities?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 3.4.2: API Gateway Security Configuration

**Learning Objective:** Configure API gateway security controls.

**Prerequisites:** Kong or other API gateway

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define Security Requirements**

List the security requirements for the API gateway:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Configure Authentication**

Configure OIDC authentication:

```yaml

```

**Step 3: Configure Rate Limiting**

Configure rate limiting:

```yaml

```

**Step 4: Configure JWT Validation**

Configure JWT validation:

```yaml

```

**Step 5: Configure OWASP Protections**

Configure OWASP API protections:

```yaml

```

**Step 6: Test Configuration**

Test each configuration:

| Test | Expected | Result |
|------|----------|--------|
| Valid JWT | | |
| Invalid JWT | | |
| Rate Limit | | |
| SQL Injection | | |
| XSS | | |

---

#### Verification

✅ Confirm authentication works
✅ Confirm rate limiting works
✅ Confirm OWASP protections work

---

#### Reflection Questions

1. What is the most important API gateway security feature?

________________________________________________________________________________
________________________________________________________________________________

2. How do you handle API versioning securely?

________________________________________________________________________________
________________________________________________________________________________

3. How do you monitor API security?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 3.5: DevSecOps CI/CD

### Exercise 3.5.1: SAST Integration

**Learning Objective:** Integrate SAST into a CI/CD pipeline.

**Prerequisites:** GitLab CI, GitHub Actions, or similar

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define SAST Requirements**

List the SAST requirements:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Choose a SAST Tool**

Compare SAST tools:

| Tool | Strengths | Weaknesses |
|------|-----------|------------|
| Semgrep | | |
| SonarQube | | |
| Checkmarx | | |
| Fortify | | |

**Step 3: Configure SAST**

Write the pipeline configuration:

```yaml

```

**Step 4: Define Rules**

Define custom SAST rules:

| Rule ID | Description | Severity |
|---------|-------------|----------|
| | | |
| | | |
| | | |

**Step 5: Test the Integration**

Test the SAST integration:

| Test | Expected | Result |
|------|----------|--------|
| Code with vulnerability | Fail | |
| Code without vulnerability | Pass | |
| Edge case | | |

---

#### Verification

✅ Confirm SAST is integrated
✅ Confirm rules are defined
✅ Confirm tests pass

---

#### Reflection Questions

1. What are the challenges of SAST integration?

________________________________________________________________________________
________________________________________________________________________________

2. How do you handle false positives in SAST?

________________________________________________________________________________
________________________________________________________________________________

3. How do you prioritize SAST findings?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 3.5.2: Pipeline Security Hardening

**Learning Objective:** Harden a CI/CD pipeline.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Identify Pipeline Risks**

List the security risks in your CI/CD pipeline:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Harden the Pipeline**

For each risk, define a hardening measure:

| Risk | Hardening Measure |
|------|-------------------|
| | |
| | |
| | |
| | |
| | |

**Step 3: Configure Secrets Management**

Describe how secrets are managed:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 4: Configure Branch Protection**

Define branch protection rules:

| Branch | Protection Rules |
|--------|------------------|
| | |
| | |
| | |

**Step 5: Configure Audit Logging**

Define audit logging requirements:

| Event | Logged? | Retention |
|-------|---------|-----------|
| Pipeline Start | | |
| Pipeline Success | | |
| Pipeline Failure | | |
| Secret Access | | |
| Configuration Change | | |

---

#### Verification

✅ Confirm risks are identified
✅ Confirm hardening measures are defined
✅ Confirm logging is configured

---

#### Reflection Questions

1. What is the most critical pipeline security risk?

________________________________________________________________________________
________________________________________________________________________________

2. How do you secure CI/CD secrets?

________________________________________________________________________________
________________________________________________________________________________

3. How do you audit pipeline activity?

________________________________________________________________________________
________________________________________________________________________________

---

# PART 4: DETECTION & RESILIENCE
## Section 4.1: SIEM/XDR Architecture

### Exercise 4.1.1: SIEM Configuration

**Learning Objective:** Configure a SIEM with log sources.

**Prerequisites:** ELK Stack or similar SIEM

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define Data Sources**

List the data sources for SIEM:

| Source | Type | Logs Provided |
|--------|------|---------------|
| | | |
| | | |
| | | |
| | | |

**Step 2: Configure Logstash Pipelines**

Write a Logstash configuration:

```conf

```

**Step 3: Define Index Patterns**

Define Elasticsearch index patterns:

| Index Pattern | Description | Retention |
|---------------|-------------|-----------|
| | | |
| | | |
| | | |

**Step 4: Create Dashboards**

Define dashboards to create:

| Dashboard | Purpose | Visualizations |
|-----------|---------|----------------|
| | | |
| | | |
| | | |

**Step 5: Test Data Ingestion**

Test log ingestion:

| Test | Expected | Result |
|------|----------|--------|
| Application Log | | |
| System Log | | |
| Security Log | | |

---

#### Verification

✅ Confirm data sources are defined
✅ Confirm pipelines are configured
✅ Confirm data is ingested

---

#### Reflection Questions

1. What are the most important logs for SIEM?

________________________________________________________________________________
________________________________________________________________________________

2. How do you handle log volume?

________________________________________________________________________________
________________________________________________________________________________

3. How do you ensure log integrity?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 4.1.2: XDR Integration

**Learning Objective:** Integrate XDR with SIEM.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define XDR Requirements**

List the XDR requirements:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Choose an XDR Tool**

Compare XDR tools:

| Tool | Strengths | Weaknesses |
|------|-----------|------------|
| CrowdStrike | | |
| SentinelOne | | |
| Microsoft Defender | | |

**Step 3: Define Integration Points**

List integration points between XDR and SIEM:

| Integration | Purpose |
|-------------|---------|
| | |
| | |
| | |

**Step 4: Configure the Integration**

Describe the integration configuration:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 5: Test the Integration**

Test the XDR integration:

| Test | Expected | Result |
|------|----------|--------|
| Endpoint Detection | | |
| Alert Forwarding | | |
| Telemetry Ingestion | | |

---

#### Verification

✅ Confirm requirements are defined
✅ Confirm integration is configured
✅ Confirm integration is tested

---

#### Reflection Questions

1. What is the value of XDR in addition to SIEM?

________________________________________________________________________________
________________________________________________________________________________

2. What are the challenges of XDR integration?

________________________________________________________________________________
________________________________________________________________________________

3. How do you handle duplicate alerts from XDR and SIEM?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 4.2: Detection Engineering

### Exercise 4.2.1: Sigma Rule Creation

**Learning Objective:** Create a Sigma detection rule.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define the Threat**

Describe the threat to detect:

- **Threat:** _________________________________________________
- **MITRE Technique:** _________________________________________________
- **Detection Log Source:** _________________________________________________
- **Detection Logic:** _________________________________________________

**Step 2: Write the Sigma Rule**

```yaml

```

**Step 3: Test the Rule**

Test with sample logs:

| Test Case | Log | Expected | Result |
|-----------|-----|----------|--------|
| Positive | | Alert | |
| Negative | | No Alert | |
| Edge Case | | | |

**Step 4: Document False Positives**

List potential false positives:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Step 5: Document Remediation**

Document how to respond if the rule triggers:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm rule is syntactically correct
✅ Confirm tests pass
✅ Confirm documentation is complete

---

#### Reflection Questions

1. How do you determine the appropriate severity level?

________________________________________________________________________________
________________________________________________________________________________

2. How do you test rules without producing false positives?

________________________________________________________________________________
________________________________________________________________________________

3. How often should rules be reviewed?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 4.2.2: MITRE ATT&CK Coverage Analysis

**Learning Objective:** Analyze and improve MITRE ATT&CK coverage.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Map Existing Detections**

Map each detection to MITRE ATT&CK techniques:

| Detection | MITRE Technique | Tactic |
|-----------|-----------------|--------|
| | | |
| | | |
| | | |
| | | |

**Step 2: Identify Coverage Gaps**

Identify uncovered techniques:

| Tactic | Techniques Covered | Techniques Uncovered |
|--------|-------------------|---------------------|
| Initial Access | | |
| Execution | | |
| Persistence | | |
| Privilege Escalation | | |
| Defense Evasion | | |
| Credential Access | | |
| Discovery | | |
| Lateral Movement | | |
| Collection | | |
| Exfiltration | | |
| Impact | | |

**Step 3: Prioritize Gaps**

Prioritize which gaps to address:

| Priority | Gap | Why |
|----------|-----|-----|
| | | |
| | | |
| | | |

**Step 4: Create Detection Plan**

Plan new detections:

| New Detection | MITRE Technique | Priority |
|---------------|-----------------|----------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm existing detections are mapped
✅ Confirm gaps are identified
✅ Confirm plan is created

---

#### Reflection Questions

1. What is the ideal MITRE ATT&CK coverage?

________________________________________________________________________________
________________________________________________________________________________

2. How do you prioritize new detections?

________________________________________________________________________________
________________________________________________________________________________

3. How do you measure detection effectiveness?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 4.3: Threat Hunting

### Exercise 4.3.1: Threat Hunting Playbook

**Learning Objective:** Create a threat hunting playbook.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define the Hunt**

| Element | Description |
|---------|-------------|
| Hunt Name | |
| Hypothesis | |
| MITRE Techniques | |
| Data Sources | |

**Step 2: Define Queries**

Write the hunt queries:

**Query 1:**
```
_________________________________________________
_________________________________________________
_________________________________________________
```

**Query 2:**
```
_________________________________________________
_________________________________________________
_________________________________________________
```

**Step 3: Define Analysis Steps**

List the analysis steps:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 4: Define Validation**

Define how findings will be validated:

| Finding | Validation Method |
|---------|-------------------|
| | |
| | |
| | |

**Step 5: Define Response**

Define response actions:

| Finding | Response Action |
|---------|-----------------|
| Confirmed Threat | |
| Suspicious | |
| False Positive | |

---

#### Verification

✅ Confirm hunt is defined
✅ Confirm queries are written
✅ Confirm response is defined

---

#### Reflection Questions

1. How do you generate hunting hypotheses?

________________________________________________________________________________
________________________________________________________________________________

2. What is the role of threat intelligence in hunting?

________________________________________________________________________________
________________________________________________________________________________

3. How do you measure hunting effectiveness?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 4.3.2: Hunting Analysis

**Learning Objective:** Perform hunting analysis on sample data.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Review Sample Data**

Review the sample data provided:

```
[Sample log data here]
```

**Step 2: Apply Hunting Hypothesis**

Apply your hypothesis to the data:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 3: Identify Anomalies**

List anomalies found:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 4: Correlate Events**

Correlate events to identify patterns:

| Event 1 | Event 2 | Correlation |
|---------|---------|-------------|
| | | |
| | | |
| | | |

**Step 5: Document Findings**

Document the hunting findings:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm anomalies are identified
✅ Confirm events are correlated
✅ Confirm findings are documented

---

#### Reflection Questions

1. What was the most surprising finding?

________________________________________________________________________________
________________________________________________________________________________

2. What additional data would have been helpful?

________________________________________________________________________________
________________________________________________________________________________

3. What recommendations would you make based on the findings?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 4.4: SOAR Automation

### Exercise 4.4.1: Playbook Design

**Learning Objective:** Design a SOAR playbook.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define the Scenario**

| Element | Description |
|---------|-------------|
| Playbook Name | |
| Trigger | |
| Severity | |
| Objectives | |

**Step 2: Define Steps**

List the playbook steps:

| Step | Action | Owner | Timeout |
|------|--------|-------|---------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |

**Step 3: Define Automation**

For each step, define what is automated:

| Step | Automated? | How |
|------|------------|-----|
| | | |
| | | |
| | | |

**Step 4: Define Escalation**

Define escalation rules:

| Condition | Escalation Action |
|-----------|-------------------|
| | |
| | |
| | |

**Step 5: Define Success Criteria**

Define when the playbook is successful:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

---

#### Verification

✅ Confirm steps are defined
✅ Confirm automation is defined
✅ Confirm success criteria are defined

---

#### Reflection Questions

1. What is the most critical part of a playbook?

________________________________________________________________________________
________________________________________________________________________________

2. How do you balance automation with manual oversight?

________________________________________________________________________________
________________________________________________________________________________

3. How do you test playbooks?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 4.4.2: Case Management Design

**Learning Objective:** Design a case management system.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define Case Fields**

Define the fields in a case:

| Field | Type | Required |
|-------|------|----------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Step 2: Define Case Workflow**

Define the case workflow states:

```
New → Investigation → Escalation → Resolution → Closure
```

Document transitions:

| From State | To State | Conditions |
|------------|----------|------------|
| | | |
| | | |
| | | |

**Step 3: Define SLA Policies**

Define SLA policies:

| Severity | Response Time | Resolution Time |
|----------|---------------|-----------------|
| CRITICAL | | |
| HIGH | | |
| MEDIUM | | |
| LOW | | |

**Step 4: Define Roles**

Define case management roles:

| Role | Permissions |
|------|-------------|
| | |
| | |
| | |

**Step 5: Define Reporting**

Define reporting requirements:

| Report | Frequency | Audience |
|--------|-----------|----------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm fields are defined
✅ Confirm workflow is defined
✅ Confirm SLA policies are defined

---

#### Reflection Questions

1. What is the most important case field?

________________________________________________________________________________
________________________________________________________________________________

2. How do you handle SLA breaches?

________________________________________________________________________________
________________________________________________________________________________

3. How do you measure case management effectiveness?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 4.5: Chaos Engineering

### Exercise 4.5.1: Chaos Test Design

**Learning Objective:** Design a chaos engineering test.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define the Test**

| Element | Description |
|---------|-------------|
| Test Name | |
| Hypothesis | |
| Failure Type | |
| Environment | |

**Step 2: Define Success Criteria**

Define when the test is successful:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 3: Define Metrics**

Define metrics to measure:

| Metric | Target | Measurement |
|--------|--------|-------------|
| | | |
| | | |
| | | |

**Step 4: Define Test Steps**

List the test steps:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 5: Define Rollback**

Define how to rollback if the test causes problems:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm test is defined
✅ Confirm success criteria are defined
✅ Confirm rollback is defined

---

#### Reflection Questions

1. What is the risk of chaos engineering?

________________________________________________________________________________
________________________________________________________________________________

2. How do you start with chaos engineering?

________________________________________________________________________________
________________________________________________________________________________

3. What is the role of chaos engineering in security?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 4.5.2: Chaos Test Execution

**Learning Objective:** Execute and analyze a chaos test.

**Prerequisites:** Gremlin or similar tool

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Prepare for Test**

Document the pre-test preparation:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Step 2: Execute the Test**

Execute the test:

| Time | Event | Observation |
|------|-------|-------------|
| | | |
| | | |
| | | |
| | | |

**Step 3: Measure Recovery**

Measure recovery:

| Metric | Value | Target |
|--------|-------|--------|
| MTTD | | |
| MTTR | | |
| Error Rate | | |

**Step 4: Analyze Results**

Analyze the test results:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**Step 5: Document Findings**

Document the findings:

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

---

#### Verification

✅ Confirm test is executed
✅ Confirm metrics are measured
✅ Confirm findings are documented

---

#### Reflection Questions

1. What was the most surprising result?

________________________________________________________________________________
________________________________________________________________________________

2. What improvements are needed?

________________________________________________________________________________
________________________________________________________________________________

3. What should be tested next?

________________________________________________________________________________
________________________________________________________________________________

---

## Section 4.6: Business Continuity

### Exercise 4.6.1: BCP Development

**Learning Objective:** Develop a Business Continuity Plan.

**Duration:** 60 minutes

---

#### Exercise Instructions

**Step 1: Define Critical Functions**

List critical business functions:

| Function | Owner | Impact of Loss |
|----------|-------|----------------|
| | | |
| | | |
| | | |
| | | |

**Step 2: Define RTO/RPO**

Define RTO/RPO for each function:

| Function | RTO | RPO | Justification |
|----------|-----|-----|---------------|
| | | | |
| | | | |
| | | | |

**Step 3: Define Recovery Strategies**

Define recovery strategies:

| Function | Strategy | How It Works |
|----------|----------|--------------|
| | | |
| | | |
| | | |

**Step 4: Define Communication Plan**

Define communication plan:

| Audience | Method | Timeline |
|----------|--------|----------|
| | | |
| | | |
| | | |

**Step 5: Define Test Plan**

Define testing plan:

| Test Type | Frequency | Owner |
|-----------|-----------|-------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm functions are defined
✅ Confirm RTO/RPO is defined
✅ Confirm recovery strategies are defined

---

#### Reflection Questions

1. What is the most critical function to protect?

________________________________________________________________________________
________________________________________________________________________________

2. What are the challenges of BCP implementation?

________________________________________________________________________________
________________________________________________________________________________

3. How do you keep the BCP current?

________________________________________________________________________________
________________________________________________________________________________

---

### Exercise 4.6.2: Backup Strategy Design

**Learning Objective:** Design a backup and recovery strategy.

**Duration:** 45 minutes

---

#### Exercise Instructions

**Step 1: Define Data Classification**

Classify data by importance:

| Data Type | Classification | RPO |
|-----------|----------------|-----|
| | | |
| | | |
| | | |

**Step 2: Define Backup Strategy**

Define backup strategy:

| Data Type | Frequency | Method | Location |
|-----------|-----------|--------|----------|
| | | | |
| | | | |
| | | | |

**Step 3: Define Immutable Backups**

Define immutable backup strategy:

| Data Type | Immutable? | Retention |
|-----------|------------|-----------|
| | | |
| | | |
| | | |

**Step 4: Define Air-Gapped Strategy**

Define air-gapped backup strategy:

| Data Type | Air-Gapped? | Retrieval Time |
|-----------|-------------|----------------|
| | | |
| | | |
| | | |

**Step 5: Define Recovery Testing**

Define recovery testing plan:

| Test | Frequency | Owner |
|------|-----------|-------|
| | | |
| | | |
| | | |

---

#### Verification

✅ Confirm data classification is defined
✅ Confirm backup strategy is defined
✅ Confirm recovery testing is defined

---

#### Reflection Questions

1. What is the most critical data to protect?

________________________________________________________________________________
________________________________________________________________________________

2. How do you balance cost with data protection?

________________________________________________________________________________
________________________________________________________________________________

3. What are the risks of air-gapped backups?

________________________________________________________________________________
________________________________________________________________________________

---

## EXERCISE SUMMARY

| Section | Exercises | Completed |
|---------|-----------|-----------|
| 1.1 SABSA | 2 | ☐ |
| 1.2 NIST CSF 2.0 | 2 | ☐ |
| 1.3 ISO 27001 | 2 | ☐ |
| 1.4 Threat Modeling | 2 | ☐ |
| 2.1 Zero Trust | 3 | ☐ |
| 2.2 IAM | 2 | ☐ |
| 2.3 PAM | 2 | ☐ |
| 2.4 Micro-segmentation | 2 | ☐ |
| 3.1 Multi-Cloud | 2 | ☐ |
| 3.2 Container Security | 2 | ☐ |
| 3.3 IaC Security | 2 | ☐ |
| 3.4 API Security | 2 | ☐ |
| 3.5 DevSecOps | 2 | ☐ |
| 4.1 SIEM/XDR | 2 | ☐ |
| 4.2 Detection Engineering | 2 | ☐ |
| 4.3 Threat Hunting | 2 | ☐ |
| 4.4 SOAR | 2 | ☐ |
| 4.5 Chaos Engineering | 2 | ☐ |
| 4.6 Business Continuity | 2 | ☐ |

**Total Exercises:** 45+

---

## FINAL CAPSTONE EXERCISE

### Capstone: Complete Security Architecture Design

**Learning Objective:** Design a complete security architecture for a scenario.

**Duration:** 3-4 hours

---

#### Scenario

A mid-sized financial services company is expanding globally. They currently have:
- On-premises data centers
- Some workloads in AWS
- No formal security architecture
- Recent security incidents
- Regulatory compliance requirements (GDPR, SOC 2)

Your task: Design a complete security architecture that addresses these challenges.

---

#### Deliverables

**1. Executive Summary**

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**2. Architecture Framework (SABSA)**

| Layer | Description |
|-------|-------------|
| Contextual | |
| Conceptual | |
| Logical | |
| Physical | |
| Component | |
| Operational | |

**3. Governance & Risk Framework**

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**4. Zero Trust Architecture**

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**5. Cloud Security Strategy**

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**6. Detection & Response Strategy**

________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________
________________________________________________________________________________

**7. Implementation Roadmap**

| Phase | Timeline | Key Activities |
|-------|----------|----------------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |

---

**[END OF STUDENT WORKBOOK]**
