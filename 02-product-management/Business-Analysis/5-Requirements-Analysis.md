# Part 2 – Requirements Engineering & Business Discovery

## Module 5: Requirements Analysis

---

### Learning Objectives

By the end of this module, you will be able to:

- Classify requirements into the appropriate categories
- Apply INVEST criteria to create well-formed user stories
- Distinguish between functional and non-functional requirements
- Identify business rules, constraints, assumptions, and dependencies
- Apply quality criteria to evaluate requirements
- Structure requirements using multiple architectural views
- Use MoSCoW and other prioritization techniques
- Create Requirements Traceability Matrices

---

## 5.1 Core Concepts: What is Requirements Analysis?

### Requirements Analysis Definition

**Requirements Analysis** is the process of evaluating, structuring, and refining requirements to ensure they are complete, clear, consistent, and feasible, before they are used for design and implementation.

**Analogy:** If elicitation is like mining for gold, analysis is like refining the ore to remove impurities and shape it into something useful. The gold (requirements) is there, but you need to analyze and refine it to create a pure, workable product.

### The Requirements Analysis Mindset

**Analysis Is NOT Elicitation:**
- Elicitation: Gathering information from stakeholders
- Analysis: Evaluating, structuring, and refining that information

**Key Analysis Activities:**
1. **Classifying:** Grouping requirements into logical categories
2. **Structuring:** Organizing into hierarchies and relationships
3. **Validating:** Ensuring requirements meet quality criteria
4. **Prioritizing:** Determining importance and sequencing
5. **Tracing:** Linking requirements to each other and to solutions

### The "So What?" Test

Every time you look at a requirement, ask: "So what?" and "Why does this matter?"

**Example:**
- **Statement:** "The system shall send appointment reminders."
- **So what?** Reminders reduce no-shows and improve patient experience.
- **Why?** Patients often forget appointments, causing inefficiency.
- **So?** This requirement must support integration with SMS and email systems.

---

## 5.2 Requirements Classification

### The Requirements Hierarchy

```
        ENTERPRISE STRATEGY
        ↓
    STRATEGIC OBJECTIVES
        ↓
     BUSINESS REQUIREMENTS
        ↓
    STAKEHOLDER REQUIREMENTS
        ↓
    SOLUTION REQUIREMENTS
        ├─── Functional Requirements
        └─── Non-Functional Requirements
        ↓
    TRANSITION REQUIREMENTS
```

### 1. Business Requirements

**Definition:** High-level statements of the goals, objectives, and needs of the organization.

**Purpose:** To articulate the business problem and solution vision.

**Characteristics:**
- Strategic in nature
- Tie back to business objectives
- Justify the project
- Typically documented in the Business Case

**MediConnect Business Requirements:**

```
BR-001: Increase patient satisfaction
  Description: Improve patient satisfaction scores from current 72% to 85%
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

BR-004: Reduce IT operating costs
  Description: Reduce IT maintenance costs from 5.5% to 4.0% of revenue
  Rationale: Legacy system costs are increasing and not delivering competitive value
  Priority: High
  Stakeholder: CFO, IT Director
```

### 2. Stakeholder Requirements

**Definition:** Statements describing the needs of specific stakeholders or stakeholder groups.

**Purpose:** To articulate what stakeholders need to achieve their goals.

**Characteristics:**
- Role-specific
- May conflict between stakeholders
- Often captured in user stories, personas

**MediConnect Stakeholder Requirements:**

```
SR-001: Clinician needs comprehensive patient view
  As a clinician, I need to see a complete patient history (including medications, allergies,
  lab results, and previous visits) in a single view, so that I can make informed clinical
  decisions quickly.
  Stakeholders: Physicians, Nurses
  Priority: Critical

SR-002: Patient needs simple appointment scheduling
  As a patient, I need to easily find available appointments and book them online, so that
  I don't have to call during business hours and wait on hold.
  Stakeholders: Patients
  Priority: High

SR-003: Admin needs to coordinate complex scheduling
  As an administrative staff member, I need to manage provider schedules, room availability,
  and patient preferences in a coordinated way, so that I can efficiently schedule without
  double-booking or conflicts.
  Stakeholders: Front Desk Staff, Practice Managers
  Priority: Critical

SR-004: IT needs integrated system management
  As IT management, I need to have a single system that integrates all clinical,
  operational, and financial functions, so that I can reduce integration complexity and
  maintenance costs.
  Stakeholders: IT Director, Operations Director
  Priority: High
```

### 3. Solution Requirements: Functional Requirements

**Definition:** Specific behaviors, features, and capabilities the solution must provide.

**Purpose:** To describe exactly what the system must do.

**Characteristics:**
- Specific and testable
- Describe system behavior
- Use active voice: "The system shall..."

**MediConnect Functional Requirements:**

```
FR-001: Patient Scheduling
  FR-001.1: The system shall allow patients to view available appointment slots online
  FR-001.2: The system shall allow patients to book appointments online
  FR-001.3: The system shall allow patients to cancel appointments online
  FR-001.4: The system shall allow patients to reschedule appointments online
  FR-001.5: The system shall send confirmation to patient after booking
  FR-001.6: The system shall send reminder 24 hours before appointment
  FR-001.7: The system shall display provider's availability based on schedule
  FR-001.8: The system shall prevent double-booking of providers or rooms
  FR-001.9: The system shall support multi-clinic scheduling

FR-002: Clinical Documentation
  FR-002.1: The system shall capture and store patient demographics
  FR-002.2: The system shall capture medical history and current medications
  FR-002.3: The system shall store past visits and treatment records
  FR-002.4: The system shall allow voice-to-text documentation (preferred)
  FR-002.5: The system shall store and display lab results
  FR-002.6: The system shall store and display imaging and diagnostic results
  FR-002.7: The system shall integrate with existing EHR data
  FR-002.8: The system shall provide clinical decision support (e.g., drug interactions)

FR-003: Billing and Revenue Cycle
  FR-003.1: The system shall capture insurance information
  FR-003.2: The system shall verify insurance eligibility
  FR-003.3: The system shall generate billing claims based on provided services
  FR-003.4: The system shall track claim status
  FR-003.5: The system shall process payments
  FR-003.6: The system shall generate patient statements

FR-004: Patient Portal
  FR-004.1: The system shall provide a secure patient portal
  FR-004.2: The system shall allow patients to view medical history
  FR-004.3: The system shall allow patients to view test results
  FR-004.4: The system shall allow patients to view upcoming appointments
  FR-004.5: The system shall allow patients to send secure messages to providers
  FR-004.6: The system shall allow patients to update contact information
  FR-004.7: The system shall allow patients to view and pay bills online

FR-005: Reporting and Analytics
  FR-005.1: The system shall provide real-time dashboards for operational metrics
  FR-005.2: The system shall generate reports on patient satisfaction
  FR-005.3: The system shall generate reports on clinical outcomes
  FR-005.4: The system shall provide financial performance reports
  FR-005.5: The system shall allow custom report creation
  FR-005.6: The system shall export data for analysis
```

### 4. Solution Requirements: Non-Functional Requirements

**Definition:** Quality attributes, performance, security, and other constraints the system must meet.

**Purpose:** To describe how the system should perform and operate.

**Characteristics:**
- Often more difficult to test
- Apply to the system as a whole
- Important for user experience

**Non-Functional Requirement Categories:**

| Category | Description | MediConnect Examples |
|----------|-------------|---------------------|
| **Performance** | Speed, responsiveness, throughput | NFR-001: System response time < 2 seconds<br>NFR-002: Support 500+ concurrent users |
| **Security** | Protection against threats | NFR-003: HIPAA-compliant security<br>NFR-004: Role-based access control |
| **Availability** | Uptime, reliability | NFR-005: 99.9% uptime SLA |
| **Scalability** | Ability to handle growth | NFR-006: Support 50% growth in users and data |
| **Usability** | User experience, accessibility | NFR-007: Intuitive clinical interface<br>NFR-008: Accessible for disabled users |
| **Maintainability** | Ease of changes, support | NFR-009: Modular system design |
| **Integrability** | System-to-system connections | NFR-010: Integration with EHR, billing, lab systems |
| **Data Quality** | Integrity, consistency | NFR-011: Data accuracy > 99.9% |
| **Compliance** | Regulatory requirements | NFR-012: HIPAA, GDPR compliance |
| **Performance** | Load and stress | NFR-013: Support all 45,000+ patients |

**Your Turn: Complete Non-Functional Requirements**

Add 5 more non-functional requirements for MediConnect:

```
NFR-014: [Category] | [Description]
NFR-015: [Category] | [Description]
NFR-016: [Category] | [Description]
NFR-017: [Category] | [Description]
NFR-018: [Category] | [Description]
```

### 5. Transition Requirements

**Definition:** Requirements for transitioning from current state to future state.

**Purpose:** To ensure successful implementation and adoption.

**Characteristics:**
- Temporary in nature
- Support the transition
- Not part of the final solution

**MediConnect Transition Requirements:**

```
TR-001: Data Migration
  Description: Legacy data from all systems must be migrated to the new platform
  Details: Data from EHR, scheduling, billing, patient portal, lab systems must be migrated
  Timeline: Before go-live
  Owner: Data Migration Team

TR-002: Training
  Description: All users must be trained on the new system before go-live
  Details: Different training for clinicians, admin, IT, management
  Timeline: 4 weeks before go-live
  Owner: Change Management Team

TR-003: Parallel Processing
  Description: New system must process simultaneously with current systems for 30 days
  Details: Ensure data consistency and validate output
  Timeline: 30 days post-go-live
  Owner: Operations Director

TR-004: Legacy System Sunset
  Description: Current systems will be decommissioned after migration validation
  Details: Data retained; systems kept available for 6 months for reference
  Timeline: 6 months post-go-live
  Owner: IT Director

TR-005: User Support
  Description: Dedicated support team for first 6 months after go-live
  Details: Help desk, escalation path, issue resolution
  Timeline: 6 months post-go-live
  Owner: IT Director
```

### 6. Business Rules, Constraints, Assumptions, and Dependencies

**Business Rules:** Policies and decisions that govern how the organization operates.

| Rule | Description | Example |
|------|-------------|---------|
| BR-001 | Policy: Appointment scheduling | Patients must be seen within 14 days for acute concerns |
| BR-002 | Policy: Insurance verification | All patients must have insurance verified before service |
| BR-003 | Policy: Patient confidentiality | HIPAA compliance, patient data protected |
| BR-004 | Policy: Scheduling priority | Urgent patients have scheduling priority |

**Constraints:** Limitations or restrictions that bound the solution.

| Constraint | Description | Example |
|------------|-------------|---------|
| C-001 | Technical constraint | Must integrate with existing billing system |
| C-002 | Budget constraint | Total project cost < $8 million |
| C-003 | Timeline constraint | Must go-live within 18 months |
| C-004 | Regulatory constraint | Must comply with HIPAA, state regulations |
| C-005 | Technical constraint | Must support current mobile platform |

**Assumptions:** What we're assuming to be true for planning purposes.

| Assumption | Description | Impact if False |
|------------|-------------|-----------------|
| A-001 | Staff will adapt to new system | Training and change management become critical |
| A-002 | Legacy data can be migrated | Project delay; data cleanup needed |
| A-003 | Integration partners will cooperate | Vendor risk; alternative needed |
| A-004 | Budget approval | Project delayed or cancelled |
| A-005 | Clinician engagement | User acceptance risk |

**Dependencies:** Things that must happen before requirements can be delivered.

| Dependency | Description | Impact |
|------------|-------------|--------|
| D-001 | Integration partner availability | Required for Phase 1 |
| D-002 | Legacy data migration completion | Required for go-live |
| D-003 | Staff training completion | Required for adoption |
| D-004 | Compliance approvals | Required for production release |
| D-005 | User acceptance testing | Required for go-live decision |

---

## 5.3 User Stories and INVEST Criteria

### Writing Effective User Stories

**User Story Template:**
```
As a [who], 
I want [what],
So that [why].
```

**MediConnect User Story Examples:**

```
STORY: Appointment Booking

As a patient,
I want to book appointments online,
So that I can schedule care without calling during business hours.

Acceptance Criteria:
1. Patient can search for appointments by:
   - Date
   - Provider
   - Clinic
2. Available slots display with provider and location
3. Patient can select, confirm, and receive confirmation
4. Confirmation includes date/time, provider, location, instructions
```

```
STORY: Clinical Documentation

As a clinician,
I want to view a complete patient history in one view,
So that I can make clinical decisions efficiently.

Acceptance Criteria:
1. View includes: demographics, medications, allergies, past visits, lab results
2. Data is organized by date (chronological)
3. Provider can filter and search data
4. View loads in < 2 seconds
```

**User Story INVEST Checklist:**

| Criterion | Description | Check |
|-----------|-------------|-------|
| **I - Independent** | Can be developed independently | [ ] |
| **N - Negotiable** | Details can be discussed and refined | [ ] |
| **V - Valuable** | Delivers business value | [ ] |
| **E - Estimable** | Team can estimate effort | [ ] |
| **S - Small** | Fits within a single sprint | [ ] |
| **T - Testable** | Has clear acceptance criteria | [ ] |

**Your Turn: Write 5 User Stories**

Create user stories for the following roles at MediConnect:

```
USER STORY 1: [Stakeholder: Patient]

As a [patient],
I want to [action],
So that [benefit].

Acceptance Criteria:
1.
2.
3.
```

```
USER STORY 2: [Stakeholder: Clinician]

As a [clinician],
I want to [action],
So that [benefit].

Acceptance Criteria:
1.
2.
3.
```

```
USER STORY 3: [Stakeholder: Admin Staff]

As a [admin staff],
I want to [action],
So that [benefit].

Acceptance Criteria:
1.
2.
3.
```

```
USER STORY 4: [Stakeholder: IT Director]

As an [IT Director],
I want to [action],
So that [benefit].

Acceptance Criteria:
1.
2.
3.
```

```
USER STORY 5: [Stakeholder: Practice Manager]

As a [practice manager],
I want to [action],
So that [benefit].

Acceptance Criteria:
1.
2.
3.
```

---

## 5.4 Requirements Quality Criteria

### The Q.U.A.L.I.T.Y. Framework

**Q - Questionable Assumptions**
- Are the requirements based on solid evidence?
- Have we validated assumptions?

**U - Unambiguous**
- Is it clear what the requirement means?
- Could different people interpret it differently?

**A - Atomic**
- Does the requirement capture one specific need?
- Can it be developed and tested independently?

**L - Legible**
- Is it easy to read and understand?
- Is it well-structured?

**I - Independent**
- Is it testable on its own?
- Does it have clear acceptance criteria?

**T - Traceable**
- Can it be traced to business needs and to solution elements?

**Y - Yours (Your Stakeholders') Needs**
- Does it truly represent what stakeholders need?
- Have we validated with stakeholders?

### Requirements Evaluation Checklist

For each requirement, check against these criteria:

```
REQUIREMENTS EVALUATION CHECKLIST

REQUIREMENT ID: [ID]
REQUIREMENT: [Description]

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

EVALUATION RESULT: [Pass/Fail]
COMMENTS: [Comments]
REFINEMENT NEEDED: [What to improve]
```

---

## 5.5 Requirements Prioritization

### Why Prioritize?

- Limited time, budget, and resources
- Not all requirements are equally important
- Helps manage scope
- Enables incremental delivery
- Focuses on what matters most

### Prioritization Techniques

#### Technique 1: MoSCoW Method

**M - Must Have:** Essential, without which the project fails
**S - Should Have:** Important but not critical
**C - Could Have:** Desirable but not essential
**W - Won't Have:** Not for this iteration/release

**MediConnect MoSCoW:**

```
MUST HAVE (Critical):
- M1: Patient scheduling (all core functions)
- M2: Clinical documentation (EHR)
- M3: Integration with existing systems
- M4: HIPAA-compliant security
- M5: Basic reporting (operational metrics)
- M6: Patient check-in
- M7: Billing (claims processing)
- M8: Role-based access control

SHOULD HAVE (Important):
- S1: Patient portal (view history, test results)
- S2: Advanced scheduling (multiple locations, resource management)
- S3: Clinical decision support (basic)
- S4: Voice-to-text documentation
- S5: Advanced dashboards
- S6: Appointment reminders (email/SMS)
- S7: Integrated lab ordering

COULD HAVE (Nice to Have):
- C1: Mobile app (patient)
- C2: AI-powered predictive scheduling
- C3: Advanced analytics (predictive)
- C4: Telehealth integration
- C5: Patient text messaging
- C6: Self-service kiosk integration

WON'T HAVE (Not This Release):
- W1: Full interoperability with all external systems
- W2: Machine learning-powered diagnostics
- W3: Full IoT integration
- W4: Blockchain for patient records
- W5: Internationalization (multi-language)
```

**Your Turn: Create MoSCoW for MediConnect**

Group the requirements you've identified into MoSCoW categories:

```
MUST HAVE (Critical):
1. [Requirement]
2. [Requirement]
3. [Requirement]
4. [Requirement]
5. [Requirement]

SHOULD HAVE (Important):
1. [Requirement]
2. [Requirement]
3. [Requirement]
4. [Requirement]

COULD HAVE (Nice to Have):
1. [Requirement]
2. [Requirement]
3. [Requirement]

WON'T HAVE (Not This Release):
1. [Requirement]
2. [Requirement]
```

#### Technique 2: Weighted Scoring

**Use When:** Requirements are multiple dimensions to consider (e.g., business value vs. cost vs. risk)

**Example: Priority Scoring:**

| Requirement | Business Value (1-5) | Cost (1-5) | Risk (1-5) | Score | Priority |
|-------------|---------------------|------------|------------|-------|----------|
| Patient Scheduling | 5 | 3 | 2 | 5.5 | 1 |
| Clinical Documentation | 5 | 4 | 3 | 4.5 | 2 |
| Billing System | 4 | 3 | 4 | 3.5 | 3 |
| Reporting | 3 | 2 | 2 | 4.0 | 4 |
| Patient Portal | 4 | 4 | 2 | 3.5 | 5 |

**Scoring Formula:**
```
Score = (Business Value × 0.6) - (Cost × 0.2) - (Risk × 0.2)
```

## 5.6 Requirements Traceability

### The Requirements Traceability Matrix (RTM)

The **Requirements Traceability Matrix** links requirements to sources, design elements, and test cases.

**Purpose:**
- Ensure all requirements are implemented
- Validate testing coverage
- Understand impact of changes
- Demonstrate completeness

**RTM Template:**

```
REQUIREMENTS TRACEABILITY MATRIX
Project: MediConnect Integrated Health Platform

| Req ID | Requirement | Source | Priority | Design Element | Test Case ID | Status |
|--------|-------------|--------|----------|----------------|--------------|--------|
| BR-001 | Increase patient satisfaction | CEO, CMO | Critical | Patient Experience | TC-PAT-001 | In Review |
| BR-002 | Reduce clinical admin time | CMO, Clinicians | Critical | Clinical Efficiency | TC-CLIN-001 | In Review |
| FR-001.1 | Online appointment booking | Patients | High | Scheduling Module | TC-SCH-001 | Draft |
| FR-001.2 | Online appointment cancellation | Patients | High | Scheduling Module | TC-SCH-002 | Draft |
| FR-001.3 | Appointment reminders | Operations | High | Notification Module | TC-NOT-001 | Draft |
| FR-002.1 | Capture demographics | Clinicians | Critical | Patient Module | TC-PAT-002 | Draft |
| FR-002.2 | Medical history capture | Clinicians | Critical | Clinical Module | TC-CLIN-002 | Draft |
| FR-003.1 | Insurance capture | Billing | High | Billing Module | TC-BILL-001 | Draft |
| FR-004.1 | Secure patient portal | Patients | High | Portal Module | TC-PORT-001 | Draft |
| NFR-001 | Response time < 2s | IT Director | High | Performance | TC-PERF-001 | Draft |
| NFR-003 | HIPAA compliance | Compliance | Critical | Security | TC-SEC-001 | Draft |
| TR-001 | Data migration | IT Director | High | Migration Plan | TC-MIG-001 | Draft |
```

---

## 5.7 Requirements Validation

### Validation vs. Verification

| Aspect | Verification | Validation |
|--------|--------------|------------|
| **Question** | "Are we building it right?" | "Are we building the right thing?" |
| **Focus** | Quality of requirements | Correctness of requirements |
| **Method** | Reviews, inspections | Stakeholder confirmation |
| **Timing** | Throughout development | Before development |

### Validation Techniques

**Technique 1: Requirements Review**

```
REQUIREMENTS REVIEW CHECKLIST

DOCUMENT: [Document Name]
DATE: [Date]
REVIEWERS: [Reviewers]

SECTION 1: ORGANIZATIONAL REVIEW
[ ] Document follows template
[ ] Formatting is consistent
[ ] Terminology is standardized
[ ] Version control is documented

SECTION 2: TECHNICAL REVIEW
[ ] Requirements are technically feasible
[ ] Performance requirements are specified
[ ] Security requirements are addressed
[ ] Integration requirements are complete
[ ] Dependencies are identified

SECTION 3: BUSINESS REVIEW
[ ] Requirements align with business strategy
[ ] Benefits are clearly stated
[ ] Costs are estimated
[ ] Risks are assessed

SECTION 4: STAKEHOLDER REVIEW
[ ] All stakeholders represented
[ ] Conflicts are resolved
[ ] Stakeholders agree with requirements

SECTION 5: QUALITY REVIEW
[ ] Requirements are unambiguous
[ ] Requirements are testable
[ ] Requirements are complete
[ ] Requirements are consistent
[ ] Requirements are atomic
[ ] Requirements are traceable

APPROVAL:
[ ] Approved by: [Name], [Title], [Date]
[ ] Rejected: [Reason]
[ ] Pending changes: [Description]
```

**Technique 2: Walkthroughs**

- Author presents requirements to stakeholders
- Walk through each requirement
- Discuss and clarify
- Capture feedback and changes
- Iterate until agreement

**Technique 3: Prototyping**

- Create low-fidelity prototypes
- Show stakeholders what the solution might look like
- Gather feedback early
- Validate requirements through visual representation

## 5.8 Hands-On: Requirements Analysis Artifacts

### Deliverable 1: Requirements Classification

Organize all requirements from your elicitation into categories:

```
REQUIREMENTS CLASSIFICATION

BUSINESS REQUIREMENTS:
- [List]

STAKEHOLDER REQUIREMENTS:
- [List]

FUNCTIONAL REQUIREMENTS:
- [List]

NON-FUNCTIONAL REQUIREMENTS:
- [List]

TRANSITION REQUIREMENTS:
- [List]

BUSINESS RULES:
- [List]

CONSTRAINTS:
- [List]

ASSUMPTIONS:
- [List]

DEPENDENCIES:
- [List]
```

### Deliverable 2: User Stories

Write a collection of user stories for each role:

```
USER STORY LIBRARY

PATIENT STORIES:
1. [User story 1]
2. [User story 2]
3. [User story 3]

CLINICIAN STORIES:
1. [User story 1]
2. [User story 2]
3. [User story 3]

ADMIN STORIES:
1. [User story 1]
2. [User story 2]
3. [User story 3]
```

### Deliverable 3: Requirements Traceability Matrix

Create a complete RTM linking all requirements to:

- Source
- Priority
- Design Elements
- Test Cases
- Status

---

## 5.9 Check Your Understanding

### Knowledge Check Questions

**1. What is the difference between a business requirement and a stakeholder requirement?**
```
[Your answer]
```

**2. What is the difference between functional and non-functional requirements?**
```
[Your answer]
```

**3. What is the INVEST acronym and what does each letter mean?**
```
[Your answer]
```

**4. What are the five categories of requirements described in BABOK?**
```
[Your answer]
```

**5. Why is requirements prioritization important?**
```
[Your answer]
```

**6. What is the MoSCoW method and what does each letter stand for?**
```
[Your answer]
```

**7. What is a Requirements Traceability Matrix and why is it important?**
```
[Your answer]
```

**8. What is the difference between verification and validation?**
```
[Your answer]
```

**9. What are business rules, constraints, assumptions, and dependencies?**
```
[Your answer]
```

**10. What are the quality criteria for requirements?**
```
[Your answer]
```

---

## 5.10 Summary & Reference

### Key Takeaways from Module 5

✅ Requirements must be classified into appropriate categories
✅ Business requirements are strategic; solution requirements are detailed
✅ Functional requirements describe what the system does
✅ Non-functional requirements describe how the system performs
✅ INVEST criteria ensure high-quality user stories
✅ MoSCoW prioritization focuses on what matters most
✅ Traceability links requirements throughout the lifecycle
✅ Verification checks quality; validation checks correctness
✅ Stakeholder confirmation is essential for validation

### Requirements Quick Reference

| Category | Purpose | Example |
|----------|---------|---------|
| **Business Requirement** | Strategic business need | "Increase patient satisfaction" |
| **Stakeholder Requirement** | Stakeholder need | "Patients need online booking" |
| **Functional Requirement** | System behavior | "System shall allow online booking" |
| **Non-Functional Requirement** | Quality attribute | "System response time < 2 seconds" |
| **Transition Requirement** | Change management | "Migrate legacy data" |
| **Business Rule** | Organizational policy | "Verify insurance before service" |
| **Constraint** | Limitation | "Budget < $8M" |
| **Assumption** | What we assume | "Staff will adapt" |
| **Dependency** | What must happen | "Integration completed" |

### Module Deliverables Checklist

You should have completed these items for your portfolio:

- [ ] Business Requirements (BR-001 to BR-00X)
- [ ] Stakeholder Requirements (SR-001 to SR-00X)
- [ ] Functional Requirements (FR-001 to FR-00X)
- [ ] Non-Functional Requirements (NFR-001 to NFR-00X)
- [ ] Transition Requirements (TR-001 to TR-00X)
- [ ] Business Rules, Constraints, Assumptions, Dependencies
- [ ] User Stories (minimum 10)
- [ ] MoSCoW Prioritization
- [ ] Requirements Traceability Matrix
- [ ] Requirements Validation Documentation

### Recommended Additional Reading

- BABOK® Guide v3, Chapter 7: Requirements Analysis and Design Definition
- "User Stories Applied" by Mike Cohn
- "Writing Effective Use Cases" by Alistair Cockburn
- "Agile Requirements Engineering" by Tobias Hoppe
- "The Software Requirements Memory Jogger" by Debra L. Sprague
