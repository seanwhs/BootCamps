# Primer 2: The Requirements Primer

## Mastering the Art and Science of Requirements

---

### Welcome to Requirements

Requirements are the **foundation of every successful project**. They are the bridge between what stakeholders need and what the development team builds. Without good requirements, projects fail—period.

This primer is your practical, hands-on guide to understanding, creating, and managing requirements. Whether you're a new BA, a developer who wants to write better requirements, or a stakeholder who wants to understand the process, this primer will give you the skills you need.

**This primer is for you if:**
- You're new to requirements and don't know where to start
- You're a BA who wants to write better requirements
- You're a developer who wants clearer requirements
- You're a stakeholder who wants to provide better input
- You're preparing for a BA certification exam

---

## What You'll Learn in This Primer

1. **What requirements actually are** (and what they are not)
2. **The 5 types of requirements** (with examples)
3. **How to write clear, testable requirements**
4. **The requirements lifecycle** (from creation to retirement)
5. **How to handle changing requirements**
6. **Common requirements mistakes** (and how to avoid them)
7. **Requirements quality checklist** (evaluate your own work)
8. **How to get requirements approved**

---

## 1. What Are Requirements? (In Plain English)

### The Simple Definition

A **requirement** is a condition or capability needed by a stakeholder to solve a problem or achieve an objective.

**In plain English:** A requirement is something the system must do, be, or have.

**The Metaphor:**

Imagine you're building a house. Requirements are like the blueprint:

- **Business requirements:** "We need a 3-bedroom house for a family of four."
- **Stakeholder requirements:** "The parents want a master bedroom with an ensuite."
- **Functional requirements:** "The house must have 3 bedrooms, 2 bathrooms, a kitchen, and a living room."
- **Non-functional requirements:** "The house must be energy-efficient, quiet, and secure."
- **Transition requirements:** "We need to move from our apartment to the house."

### What Requirements Are NOT

| What They Are | What They Are NOT |
|---------------|-------------------|
| Needs and capabilities | Solutions or designs |
| What the system must do | How the system will do it |
| Conditions for success | Implementation details |
| Stakeholder needs | Technical specifications |
| Business value | Features |

**Example of the Difference:**

| Not a Requirement (Solution) | Requirement (Need) |
|------------------------------|-------------------|
| "We need a patient portal." | "Patients need to schedule appointments online." |
| "We need a cloud-based system." | "The system must be accessible from any location." |
| "We need a mobile app." | "Users need to access the system on mobile devices." |
| "We need a database." | "The system must store patient records securely." |

---

## 2. The 5 Types of Requirements

### The Requirements Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ENTERPRISE STRATEGY                                │
│  (What the organization wants to achieve)                              │
│                                                                         │
│  "Become the leading healthcare provider in the region."              │
└─────────────────────────────────────────────────────────────────────────┘
                                                                           │
                                                                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     BUSINESS REQUIREMENTS (BRs)                        │
│  (High-level statements of business objectives)                        │
│                                                                         │
│  BR-001: "Increase patient satisfaction from 72% to 85%"               │
│  BR-002: "Reduce clinician administrative burden by 30%"               │
└─────────────────────────────────────────────────────────────────────────┘
                                                                           │
                                                                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     STAKEHOLDER REQUIREMENTS (SRs)                      │
│  (Needs of specific stakeholder groups)                                 │
│                                                                         │
│  SR-001: "Patients need to book appointments online"                   │
│  SR-002: "Clinicians need a unified view of patient records"           │
└─────────────────────────────────────────────────────────────────────────┘
                                                                           │
                                                                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     SOLUTION REQUIREMENTS                              │
│  (What the solution must do and how it must perform)                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  FUNCTIONAL REQUIREMENTS (FRs)                                  │   │
│  │  "What the system must do"                                      │   │
│  │  FR-001: "System shall allow patients to book online"          │   │
│  │  FR-002: "System shall store patient medical records"          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  NON-FUNCTIONAL REQUIREMENTS (NFRs)                             │   │
│  │  "How the system must perform"                                 │   │
│  │  NFR-001: "System response time < 2 seconds"                   │   │
│  │  NFR-002: "System must be HIPAA-compliant"                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                                                           │
                                                                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     TRANSITION REQUIREMENTS (TRs)                       │
│  (Temporary requirements for moving from current to future state)      │
│                                                                         │
│  TR-001: "Legacy data must be migrated before go-live"                 │
│  TR-002: "All staff must be trained before go-live"                    │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Business Requirements (BRs)

**Definition:** High-level statements of the goals, objectives, and needs of the organization.

**Characteristics:**
- Strategic in nature
- Tie back to business objectives
- Justify the project

**Format:**
```
BR-XXX: [Requirement Name]
  Description: [Clear description of the business need]
  Rationale: [Why this is needed]
  Priority: [Critical/High/Medium/Low]
  Stakeholder: [Key stakeholders]
```

**Examples:**

```
BR-001: Increase patient satisfaction
  Description: Improve patient satisfaction scores from 72% to 85%
  Rationale: Declining satisfaction has resulted in 15% patient attrition
  Priority: Critical
  Stakeholder: CEO, CMO

BR-002: Reduce clinician administrative burden
  Description: Decrease clinician time spent on administrative tasks from 40% to 25%
  Rationale: Clinician burnout is increasing and affecting retention
  Priority: Critical
  Stakeholder: CMO, Clinicians

BR-003: Improve operational efficiency
  Description: Reduce scheduling-related manual coordination time by 30%
  Rationale: Scheduling inefficiency is driving operational costs and staff frustration
  Priority: High
  Stakeholder: Operations Director
```

### 2.2 Stakeholder Requirements (SRs)

**Definition:** Statements describing the needs of specific stakeholder groups.

**Characteristics:**
- Role-specific
- May conflict between stakeholders
- Often captured in user stories

**Format:**
```
SR-XXX: [Requirement Name]
  Description: [Clear description of the stakeholder need]
  Stakeholder(s): [Who needs this?]
  Priority: [Critical/High/Medium/Low]
```

**Examples:**

```
SR-001: Clinician needs comprehensive patient view
  Description: As a clinician, I need to see a complete patient history
  (including medications, allergies, lab results, and previous visits)
  in a single view, so that I can make informed clinical decisions quickly.
  Stakeholder(s): Physicians, Nurses
  Priority: Critical

SR-002: Patient needs simple appointment scheduling
  Description: As a patient, I need to easily find available appointments and
  book them online, so that I don't have to call during business hours.
  Stakeholder(s): Patients
  Priority: High

SR-003: Admin needs to coordinate complex scheduling
  Description: As an administrative staff member, I need to manage provider
  schedules, room availability, and patient preferences in a coordinated way,
  so that I can efficiently schedule without double-booking or conflicts.
  Stakeholder(s): Front Desk Staff, Practice Managers
  Priority: Critical
```

### 2.3 Functional Requirements (FRs)

**Definition:** Specific behaviors, features, and capabilities the solution must provide.

**Characteristics:**
- Specific and testable
- Describe system behavior
- Use active voice: "The system shall..."

**Format:**
```
FR-XXX.X: [Requirement Name]
  Description: [Detailed description]
  Acceptance Criteria:
  - [Criterion 1]
  - [Criterion 2]
  - [Criterion 3]
  Priority: [Critical/High/Medium/Low]
  Source: [Stakeholder/Group]
```

**Examples:**

```
FR-001.1: Online Appointment Booking
  Description: The system shall allow patients to view available appointment slots online
  Acceptance Criteria:
  - Patient can search for appointments by date
  - Patient can search for appointments by provider
  - Patient can search for appointments by clinic
  - Available slots display with provider and location
  Priority: Critical
  Source: Patients

FR-001.2: Online Appointment Cancellation
  Description: The system shall allow patients to cancel appointments online
  Acceptance Criteria:
  - Patient can view upcoming appointments
  - Patient can select an appointment to cancel
  - Patient receives confirmation of cancellation
  - System updates provider schedule
  Priority: High
  Source: Patients

FR-002.1: Patient Demographics Capture
  Description: The system shall capture and store patient demographics
  Acceptance Criteria:
  - System captures: name, DOB, gender, address, phone, email
  - All fields validated for format and completeness
  - Data stored securely with audit trail
  - Data available for clinical and operational use
  Priority: Critical
  Source: Clinicians, Admin
```

### 2.4 Non-Functional Requirements (NFRs)

**Definition:** Quality attributes, performance, security, and other constraints.

**Characteristics:**
- Often more difficult to test
- Apply to the system as a whole
- Important for user experience

**Categories:**

| Category | Description | Example |
|----------|-------------|---------|
| **Performance** | Speed, responsiveness, throughput | "System response time < 2 seconds" |
| **Security** | Protection against threats | "HIPAA-compliant security" |
| **Availability** | Uptime, reliability | "99.9% uptime SLA" |
| **Scalability** | Ability to handle growth | "Support 50% growth in users and data" |
| **Usability** | User experience, accessibility | "Intuitive clinical interface" |
| **Maintainability** | Ease of changes, support | "Modular system design" |
| **Integrability** | System-to-system connections | "Integration with EHR, billing, lab systems" |
| **Compliance** | Regulatory requirements | "HIPAA, GDPR compliance" |

**Format:**
```
NFR-XXX: [Requirement Name]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]
```

**Examples:**

```
NFR-001: Response Time
  Description: System response time shall be less than 2 seconds for all user interactions
  Test Criteria: Load testing with 500 concurrent users, average response time measured
  Priority: High

NFR-003: HIPAA Compliance
  Description: System must be fully HIPAA-compliant
  Test Criteria: HIPAA compliance audit, all controls documented and tested
  Priority: Critical

NFR-005: System Availability
  Description: System shall have 99.9% uptime availability SLA
  Test Criteria: Uptime monitoring over 6-month period
  Priority: High

NFR-009: User Adoption
  Description: System shall achieve 80% user adoption within 3 months
  Test Criteria: User adoption metrics, user satisfaction surveys
  Priority: High
```

### 2.5 Transition Requirements (TRs)

**Definition:** Requirements for transitioning from current state to future state.

**Characteristics:**
- Temporary in nature
- Support the transition
- Not part of the final solution

**Format:**
```
TR-XXX: [Requirement Name]
  Description: [Description]
  Timeline: [When needed]
  Owner: [Who is responsible]
```

**Examples:**

```
TR-001: Data Migration
  Description: Legacy data from all systems must be migrated to the new platform
  Details: Data from EHR, scheduling, billing, patient portal, lab systems must be migrated
  Timeline: Before go-live
  Owner: Data Migration Team

TR-002: User Training
  Description: All users must be trained on the new system before go-live
  Details: Different training for clinicians, admin, IT, management
  Timeline: 4 weeks before go-live
  Owner: Change Management Team

TR-003: Parallel Processing
  Description: New system must process simultaneously with current systems for 30 days
  Details: Ensure data consistency and validate output
  Timeline: 30 days post-go-live
  Owner: Operations Director
```

### 2.6 Supporting Information

**Business Rules:** Policies and decisions that govern how the organization operates.

| Rule | Description | Example |
|------|-------------|---------|
| BR-001 | Insurance verification | All patients must have insurance verified before service |
| BR-002 | Appointment scheduling | Patients must be seen within 14 days for acute concerns |
| BR-003 | Patient confidentiality | HIPAA compliance, patient data protected |

**Constraints:** Limitations or restrictions that bound the solution.

| Constraint | Description | Example |
|------------|-------------|---------|
| C-001 | Technical constraint | Must integrate with existing billing system |
| C-002 | Budget constraint | Total project cost < $8 million |
| C-003 | Timeline constraint | Must go-live within 18 months |

**Assumptions:** What we're assuming to be true for planning purposes.

| Assumption | Description | Impact if False |
|------------|-------------|-----------------|
| A-001 | Staff will adapt | Training and change management become critical |
| A-002 | Budget approval | Project delayed or cancelled |

**Dependencies:** Things that must happen before requirements can be delivered.

| Dependency | Description | Impact |
|------------|-------------|--------|
| D-001 | Integration partner availability | Required for Phase 1 |
| D-002 | Legacy data migration completion | Required for go-live |

---

## 3. How to Write Clear, Testable Requirements

### The 10 Quality Criteria

**1. Correct**

- Does it accurately reflect stakeholder needs?
- Is it technically accurate?
- Has it been validated with stakeholders?

**Example:**
- **Poor:** "The system should be fast."
- **Good:** "The system shall return patient search results in less than 2 seconds."

**2. Complete**

- Does it capture the entire need?
- Are all scenarios covered?
- Are all conditions stated?

**Example:**
- **Poor:** "The system shall book appointments."
- **Good:** "The system shall allow patients to book, reschedule, and cancel appointments, with confirmation sent via email and SMS."

**3. Consistent**

- Does it conflict with other requirements?
- Is terminology consistent?
- Is format consistent?

**Example:**
- **Poor:** "Patient data shall be stored." (elsewhere: "Patient records shall be saved.")
- **Good:** Always use the same term: "Patient records shall be stored."

**4. Testable**

- Can it be tested?
- Are acceptance criteria defined?
- Are success/failure conditions clear?

**Example:**
- **Poor:** "The system shall be user-friendly."
- **Good:** "The system shall have a net promoter score (NPS) of at least 50 based on user surveys."

**5. Traceable**

- Can it be traced to a business need?
- Can it be traced to stakeholders?
- Can it be traced to solution elements?

**Example:**
- **Poor:** "The system shall have a portal." (No link to business need)
- **Good:** "The system shall have a patient portal (FR-004.1) to enable online scheduling (BR-001: Patient satisfaction)."

**6. Feasible**

- Is it technically feasible?
- Is it operationally feasible?
- Is it within budget and timeline?

**Example:**
- **Poor:** "The system shall use AI to diagnose all conditions." (Not feasible)
- **Good:** "The system shall support AI-assisted diagnosis for common conditions, starting with pilot."

**7. Atomic**

- Does it capture one specific need?
- Is it independent from other requirements?

**Example:**
- **Poor:** "The system shall support scheduling and billing." (Two things)
- **Good:** "The system shall support scheduling." and "The system shall support billing."

**8. Unambiguous**

- Is it clear and precise?
- Is it free from jargon?
- Does it use standard terminology?

**Example:**
- **Poor:** "The system shall handle patient records."
- **Good:** "The system shall allow clinicians to create, read, update, and delete patient records."

**9. Prioritized**

- Is its priority documented?
- Is the priority justified?
- Does it align with business priorities?

**Example:**
- **Poor:** "The system shall have patient portal." (No priority)
- **Good:** "The system shall have patient portal. Priority: High. Rationale: Critical for patient satisfaction."

**10. Approved**

- Has it been approved by stakeholders?
- Is approval documented?
- Is the approver authorized?

**Example:**
- **Poor:** "Requirements agreed with team." (Vague)
- **Good:** "Requirements approved by Sarah Chen (CEO), Dr. Michael Rodriguez (CMO) on [Date]."

### The INVEST Criteria (for User Stories)

| Criterion | Description |
|-----------|-------------|
| **I**ndependent | Can be developed independently |
| **N**egotiable | Details can be discussed and refined |
| **V**aluable | Delivers business value |
| **E**stimable | Team can estimate effort |
| **S**mall | Fits within a single sprint |
| **T**estable | Has clear acceptance criteria |

### The 5 "Whys" for Requirements

```
Why #1: Why is this requirement needed?
Why #2: Why does that matter?
Why #3: Why is that important?
Why #4: Why would that be a problem?
Why #5: What is the root need?

Example:
FR-001.1: System shall allow patients to book appointments online.
  Why #1? Patients need to book appointments.
  Why #2? Currently patients have to call and often wait on hold.
  Why #3? This causes frustration and some patients don't rebook.
  Why #4? We're losing patients to competitors with online booking.
  Why #5? We need to improve patient retention and satisfaction.
```

---

## 4. The Requirements Lifecycle

### The Full Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    REQUIREMENTS LIFECYCLE                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. ELICIT                                                              │
│     Gather requirements from stakeholders                              │
│     ↓                                                                   │
│  2. ANALYZE                                                             │
│     Evaluate, structure, and refine requirements                       │
│     ↓                                                                   │
│  3. SPECIFY                                                             │
│     Document requirements in appropriate format                        │
│     ↓                                                                   │
│  4. VALIDATE                                                            │
│     Confirm requirements meet stakeholder needs                        │
│     ↓                                                                   │
│  5. APPROVE                                                             │
│     Obtain formal stakeholder sign-off                                 │
│     ↓                                                                   │
│  6. MANAGE                                                              │
│     Track changes, maintain traceability                               │
│     ↓                                                                   │
│  7. TRACE                                                               │
│     Link requirements to design, tests, implementation                 │
│     ↓                                                                   │
│  8. VERIFY                                                              │
│     Ensure requirements are implemented correctly                       │
│     ↓                                                                   │
│  9. RETIRE                                                              │
│     Decommission requirements when no longer needed                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phase 1: Elicitation

**What it is:** Gathering requirements from stakeholders.

**Techniques:**
- Interviews
- Workshops
- Observation
- Surveys
- Document analysis

**Output:** Raw requirements, notes, findings

### Phase 2: Analysis

**What it is:** Evaluating, structuring, and refining requirements.

**Activities:**
- Classifying requirements
- Resolving conflicts
- Prioritizing
- Identifying gaps

**Output:** Refined, organized requirements

### Phase 3: Specification

**What it is:** Documenting requirements in appropriate format.

**Formats:**
- BRD (Business Requirements Document)
- User Stories
- Use Cases
- Functional Specifications

**Output:** Documented requirements

### Phase 4: Validation

**What it is:** Confirming requirements meet stakeholder needs.

**Activities:**
- Walkthroughs
- Reviews
- Prototyping
- Stakeholder confirmation

**Output:** Validated requirements

### Phase 5: Approval

**What it is:** Obtaining formal stakeholder sign-off.

**Activities:**
- Presenting requirements
- Addressing concerns
- Getting signatures

**Output:** Approved requirements

### Phase 6: Management

**What it is:** Tracking changes and maintaining traceability.

**Activities:**
- Change management
- Version control
- Impact analysis

**Output:** Managed requirements

### Phase 7: Traceability

**What it is:** Linking requirements to design, tests, and implementation.

**Activity:** Creating and maintaining RTM

**Output:** Traceable requirements

### Phase 8: Verification

**What it is:** Ensuring requirements are implemented correctly.

**Activity:** Testing and QA

**Output:** Verified requirements

### Phase 9: Retirement

**What it is:** Decommissioning requirements when no longer needed.

**Activity:** Archiving

**Output:** Retired requirements

---

## 5. How to Handle Changing Requirements

### The Reality of Change

**Change is inevitable.** The question is not whether requirements will change, but how you handle them.

**Why Requirements Change:**

| Reason | Example |
|--------|---------|
| Business needs change | New strategic priorities |
| Stakeholders learn more | Users realize they need more features |
| Technical constraints | Limitations discovered during development |
| Competitive pressure | Competitors launch new features |
| Regulatory changes | New compliance requirements |

### The Change Management Process

```
1. CHANGE REQUEST
   ↓
   Someone requests a change (stakeholder, developer, BA)

2. EVALUATE IMPACT
   ↓
   What is affected? (Requirements, design, code, schedule, budget)

3. ANALYSIS
   ↓
   What are the alternatives? What are the trade-offs?

4. DECISION
   ↓
   Approve, reject, or defer the change

5. IMPLEMENT
   ↓
   If approved, implement the change

6. COMMUNICATE
   ↓
   Let stakeholders know what changed and why

7. UPDATE
   ↓
   Update all affected documentation
```

### Impact Analysis Template

```
IMPACT ANALYSIS

CHANGE REQUEST ID: [ID]
REQUESTOR: [Name]
DATE: [Date]
DESCRIPTION: [What is being requested]

AFFECTED REQUIREMENTS:
1. [Requirement ID] - [Description]
2. [Requirement ID] - [Description]
3. [Requirement ID] - [Description]

AFFECTED DESIGN:
1. [Component] - [Impact]
2. [Component] - [Impact]

AFFECTED CODE:
1. [Module] - [Impact]
2. [Module] - [Impact]

AFFECTED TESTS:
1. [Test Case ID] - [Impact]
2. [Test Case ID] - [Impact]

SCHEDULE IMPACT: [Days/Weeks/Months]
COST IMPACT: [Amount or %]
QUALITY IMPACT: [Risk description]

RECOMMENDATION: [Approve/Reject/Defer]
RATIONALE: [Why?]

APPROVED BY: [Name/Title] [Date]
```

### Best Practices for Managing Change

1. **Expect changes:** Plan for them from the start
2. **Use a formal process:** Not all changes are equal
3. **Assess impact:** Know what you're getting into
4. **Communicate:** Everyone needs to know about changes
5. **Document:** What changed, why, and when
6. **Trace:** Link changes to affected artifacts
7. **Stay flexible:** Sometimes changes are the right choice

---

## 6. Common Requirements Mistakes (And How to Avoid Them)

### Mistake 1: Writing Solutions, Not Requirements

**The Problem:**
> "We need a cloud-based system with a patient portal."

**The Solution:**
> "Patients need to access their medical records and schedule appointments from anywhere at any time."

**How to Avoid:**
- Always ask "Why?"
- Focus on the problem, not the solution
- Describe what users need to achieve

### Mistake 2: Being Too Vague

**The Problem:**
> "The system should be user-friendly."

**The Solution:**
> "The system shall have a Net Promoter Score (NPS) of at least 50 and a System Usability Scale (SUS) score of at least 70."

**How to Avoid:**
- Be specific
- Use measurable criteria
- Define what "good" looks like

### Mistake 3: Forgetting Non-Functional Requirements

**The Problem:**
> All requirements focus on features, nothing on performance, security, or usability.

**The Solution:**
> Include NFRs for: performance, security, availability, scalability, usability, maintainability, integration, and compliance.

**How to Avoid:**
- Dedicate specific sessions to NFRs
- Use a checklist of NFR categories
- Ask "How should this perform?"

### Mistake 4: Not Validating with Stakeholders

**The Problem:**
> You write requirements and assume they're correct.

**The Solution:**
> "I've drafted the requirements. Can you review them? Are there any gaps or misunderstandings?"

**How to Avoid:**
- Always validate
- Use walkthroughs
- Get formal sign-off

### Mistake 5: Writing Requirements That Aren't Testable

**The Problem:**
> "The system shall be reliable."

**The Solution:**
> "The system shall have 99.9% uptime, measured over a 3-month period."

**How to Avoid:**
- Always define acceptance criteria
- Use "shall" statements
- Make it measurable

### Mistake 6: Not Managing Changes

**The Problem:**
> Changes are made informally, and nobody updates the documentation.

**The Solution:**
> "We've discussed the change. Let me document it and get it approved."

**How to Avoid:**
- Use a formal change process
- Update documentation
- Communicate changes

### Mistake 7: Writing Requirements Without Traceability

**The Problem:**
> "We have requirements, but we don't know which tests cover them."

**The Solution:**
> "I'll map each requirement to at least one test case using our RTM."

**How to Avoid:**
- Create an RTM
- Link requirements to tests
- Maintain traceability

### Mistake 8: Not Writing Requirements at the Right Level

**The Problem:**
> Too vague at the top level, too detailed for business, too high-level for developers.

**The Solution:**
> Business requirements (strategic), functional requirements (detailed), and user stories (implementation-ready).

**How to Avoid:**
- Understand your audience
- Write at the right level
- Use different formats for different audiences

---

## 7. Requirements Quality Checklist

### Self-Assessment Tool

```
REQUIREMENTS QUALITY CHECKLIST

Requirement ID: [ID]
Requirement Description: [Description]

1. CORRECTNESS
   [ ] Is it technically accurate?
   [ ] Does it accurately reflect stakeholder needs?
   [ ] Has it been validated with stakeholders?

2. COMPLETENESS
   [ ] Does it capture the complete need?
   [ ] Are all scenarios covered?
   [ ] Are all conditions stated?

3. CONSISTENCY
   [ ] Does it conflict with other requirements?
   [ ] Is the terminology consistent?
   [ ] Is the format consistent?

4. TESTABLE
   [ ] Can it be tested?
   [ ] Are acceptance criteria defined?
   [ ] Are success/failure conditions clear?

5. TRACEABLE
   [ ] Can it be traced to a business need?
   [ ] Can it be traced to stakeholders?
   [ ] Can it be traced to solution elements?

6. FEASIBLE
   [ ] Is it technically feasible?
   [ ] Is it operationally feasible?
   [ ] Is it within budget and timeline?

7. ATOMIC
   [ ] Does it capture one specific need?
   [ ] Is it independent from other requirements?

8. UNAMBIGUOUS
   [ ] Is it clear and precise?
   [ ] Is it free from jargon?
   [ ] Does it use standard terminology?

9. PRIORITIZED
   [ ] Is its priority documented?
   [ ] Is the priority justified?
   [ ] Does it align with business priorities?

10. APPROVED
    [ ] Has it been approved by stakeholders?
    [ ] Is the approval documented?
    [ ] Is the approver authorized?

EVALUATION RESULT: [Pass / Needs Revision / Fail]
REVISION NEEDED: [What needs to change]
```

### Quick Checklist for User Stories

```
USER STORY INVEST CHECKLIST

Story: [Description]

[ ] Independent: Can be developed independently
[ ] Negotiable: Details can be discussed
[ ] Valuable: Delivers business value
[ ] Estimable: Team can estimate effort
[ ] Small: Fits within one sprint
[ ] Testable: Clear acceptance criteria

RESULT: [Ready / Needs Refinement]
```

---

## 8. How to Get Requirements Approved

### The Approval Process

```
1. PREPARE
   ↓
   Ensure requirements are complete, clear, and validated

2. PRESENT
   ↓
   Walk stakeholders through the requirements

3. ADDRESS CONCERNS
   ↓
   Discuss and resolve any issues

4. GET SIGN-OFF
   ↓
   Obtain formal approval

5. DOCUMENT
   ↓
   Record the approval
```

### Stakeholder Sign-off Template

```
REQUIREMENTS SIGN-OFF

PROJECT: [Project Name]
REQUIREMENTS VERSION: [Version]
DATE: [Date]

BY SIGNING BELOW, I ACKNOWLEDGE THAT:
- I have reviewed the requirements document
- The requirements accurately reflect the business needs
- I agree to the priorities assigned to requirements
- I understand that changes will follow the change management process

STAKEHOLDER APPROVALS:

Name: ___________________ Title: ___________________
Signature: ___________________ Date: ___________________

Name: ___________________ Title: ___________________
Signature: ___________________ Date: ___________________

Name: ___________________ Title: ___________________
Signature: ___________________ Date: ___________________

BA APPROVAL:
Name: ___________________ Title: ___________________
Signature: ___________________ Date: ___________________
```

### Tips for Getting Approval

1. **Prepare thoroughly:** Know your requirements inside out
2. **Use visual aids:** Diagrams help people understand
3. **Focus on business value:** Remind stakeholders why this matters
4. **Address concerns directly:** Don't avoid difficult questions
5. **Set expectations:** Explain the change management process
6. **Document everything:** Keep a record of approvals

---

## 9. Quick Reference: Requirements Formats

### 9.1 Business Requirements Format

```
BR-XXX: [Requirement Name]
  Description: [Clear description]
  Rationale: [Why needed]
  Priority: [Critical/High/Medium/Low]
  Stakeholder: [Key stakeholders]
```

### 9.2 Functional Requirements Format

```
FR-XXX.X: [Requirement Name]
  Description: [Detailed description]
  Acceptance Criteria:
  - [Criterion 1]
  - [Criterion 2]
  - [Criterion 3]
  Priority: [Critical/High/Medium/Low]
  Source: [Stakeholder/Group]
```

### 9.3 User Story Format

```
As a [who],
I want [what],
So that [why].

Acceptance Criteria:
1. [Criterion 1]
2. [Criterion 2]
3. [Criterion 3]
```

### 9.4 Use Case Format

```
USE CASE: [Name]

Use Case ID: [UC-XXX]
Actors: [List]
Description: [Brief description]
Preconditions: [What must be true before]
Postconditions: [What must be true after]

BASIC FLOW:
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4]
5. [Step 5]

ALTERNATE FLOWS:
A1: [Description]
  1. [Step 1]
  2. [Step 2]

EXCEPTIONS:
E1: [Description]
  1. [Step 1]
  2. [Step 2]
```

### 9.5 Non-Functional Requirements Format

```
NFR-XXX: [Requirement Name]
  Category: [Performance/Security/Usability/etc.]
  Description: [Detailed description]
  Test Criteria: [How to measure]
  Priority: [Critical/High/Medium/Low]
```

---

## 10. Requirements Vocabulary (Key Terms)

| Term | Definition |
|------|------------|
| **Requirement** | A condition or capability needed by a stakeholder |
| **Functional Requirement** | What the system must do |
| **Non-Functional Requirement** | How the system must perform |
| **Business Requirement** | High-level business objective |
| **Stakeholder Requirement** | Need of a specific stakeholder group |
| **Transition Requirement** | Temporary requirement for moving to future state |
| **Acceptance Criteria** | Conditions for a requirement to be met |
| **Traceability** | Linking requirements to other artifacts |
| **Validation** | Confirming requirements meet stakeholder needs |
| **Verification** | Ensuring requirements are implemented correctly |
| **Prioritization** | Ordering requirements by importance |
| **Change Management** | Process for handling requirement changes |
| **Elicitation** | Gathering requirements from stakeholders |
| **Analysis** | Evaluating and structuring requirements |

---

## What's Next?

Now that you've completed this primer, you're ready to:

1. **Practice writing requirements** using the templates in this primer
2. **Apply the quality checklist** to your own requirements
3. **Learn the full BA lifecycle** in the Master Business Analysis Series
4. **Try the case studies** in Appendix B
5. **Get certified** (ECBA, CCBA, CBAP)

---

**END OF PRIMER 2**

*This primer is your practical guide to requirements—the foundation of every successful project. Keep it handy as you work with requirements in your projects.*
