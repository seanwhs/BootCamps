# Part 2 – Requirements Engineering & Business Discovery

## Module 6: Requirements Documentation

---

### Learning Objectives

By the end of this module, you will be able to:

- Structure and write a complete Business Requirements Document (BRD)
- Create epics, features, and themes for Agile requirements
- Write detailed use case specifications
- Design user journey maps for stakeholder experiences
- Document decision tables and decision trees
- Build a comprehensive product backlog
- Produce a complete Requirements Package

---

## 6.1 Core Concepts: The Art of Requirements Documentation

### Why Documentation Matters

**Documentation serves multiple purposes:**

1. **Communication:** Ensures everyone understands the requirements the same way
2. **Memory:** Captures knowledge that would otherwise be forgotten
3. **Traceability:** Links requirements to business needs and solution elements
4. **Sign-off:** Formal agreement on what will be built
5. **Transition:** Supports knowledge transfer to new team members
6. **Audit:** Demonstrates due diligence and regulatory compliance
7. **Contracts:** Supports vendor agreements and contracts
8. **Baseline:** Provides a reference point for change control

**Analogy:** If building a house is like a construction project, requirements documentation is the architectural blueprint. You wouldn't build a house without blueprints, so why build software without requirements documentation?

### Documenting vs. Over-Documenting

**The Goldilocks Principle:**

| Too Little Documentation | Just Right | Too Much Documentation |
|--------------------------|------------|----------------------|
| Vague, unclear requirements | Clear, complete requirements | Excessive detail, endless documents |
| Different interpretations | Shared understanding | Paralysis by analysis |
| Missed requirements | All requirements captured | Analysis paralysis |
| Rework and failure | Successful delivery | Delayed delivery |
| High risk | Managed risk | Low risk but high overhead |

**Key Principle:** Document enough to ensure clarity and reduce risk, but not so much that it slows down delivery. Different projects require different levels of documentation.

### Documentation Types by Project Approach

| Approach | Key Artifacts | Detail Level |
|----------|---------------|--------------|
| **Waterfall** | BRD, FRS, Use Cases, Technical Specs | High detail, formal |
| **Agile** | Product Backlog, User Stories, Acceptance Criteria | Just-in-time, concise |
| **Hybrid** | Combination of BRD and User Stories | Adaptive to need |

---

## 6.2 The Business Requirements Document (BRD)

### BRD Overview

The **Business Requirements Document (BRD)** is the primary artifact for business requirements. It defines what the business needs, why it's needed, and the high-level requirements for the solution.

**What the BRD Is NOT:**
- It's not a technical design document
- It's not a project plan
- It's not a contract

**What the BRD IS:**
- A business-focused requirements document
- A communication tool between business and technical stakeholders
- A basis for developing the solution

### Complete BRD Template

```
BUSINESS REQUIREMENTS DOCUMENT

Project Name: [Name]
Document Version: [Version]
Document Owner: [Name]
Date: [Date]

TABLE OF CONTENTS

1. Executive Summary
2. Project Scope
3. Business Objectives
4. Stakeholders
5. Business Requirements
6. Functional Requirements
7. Non-Functional Requirements
8. Business Rules
9. Constraints and Assumptions
10. Dependencies
11. Transition Requirements
12. Glossary
13. Appendix

APPROVAL
    Approved by: ___________________ (Name/Title)
    Date: ___________________
```

### Section 1: Executive Summary

**Template:**
```
1. EXECUTIVE SUMMARY

1.1 Purpose of Document
This Business Requirements Document (BRD) defines the business needs,
objectives, and requirements for the [Project Name].

1.2 Business Context
[Brief description of the business situation and why this project is needed.]

1.3 Key Stakeholders
[High-level summary of key stakeholder groups.]

1.4 High-Level Solution
[Brief description of the proposed solution approach.]

1.5 Expected Outcomes
[Summary of key benefits and expected outcomes.]
```

### Section 2: Project Scope

**Template:**
```
2. PROJECT SCOPE

2.1 In-Scope
The following areas are within the scope of this project:
- [Area 1]
- [Area 2]
- [Area 3]

2.2 Out-of-Scope
The following areas are NOT within scope:
- [Area 1]
- [Area 2]
- [Area 3]

2.3 Assumptions
- [Assumption 1]
- [Assumption 2]
- [Assumption 3]

2.4 Constraints
- [Constraint 1]
- [Constraint 2]
- [Constraint 3]
```

### Section 3: Business Objectives

**Template:**
```
3. BUSINESS OBJECTIVES

3.1 Strategic Objectives
The project supports the following strategic objectives:
1. [Strategic objective 1]
2. [Strategic objective 2]
3. [Strategic objective 3]

3.2 Measurable Outcomes
The following measurable outcomes define project success:

| Objective | Metric | Baseline | Target | Owner |
|-----------|--------|----------|--------|-------|
| [Objective 1] | [Metric 1] | [Baseline] | [Target] | [Owner] |
| [Objective 2] | [Metric 2] | [Baseline] | [Target] | [Owner] |
| [Objective 3] | [Metric 3] | [Baseline] | [Target] | [Owner] |

3.3 Business Case
[Brief business case summary including investment, benefits, and ROI.]
```

### Section 4: Stakeholders

**Template:**
```
4. STAKEHOLDERS

4.1 Key Stakeholders
| ID | Name/Title | Role | Department | Key Interests |
|----|------------|------|------------|---------------|
| S-001 | [Name] | [Role] | [Dept] | [Interest] |
| S-002 | [Name] | [Role] | [Dept] | [Interest] |
| S-003 | [Name] | [Role] | [Dept] | [Interest] |

4.2 Stakeholder Groups
- [Group 1]: [Description]
- [Group 2]: [Description]
- [Group 3]: [Description]
```

### Section 5: Business Requirements (BRs)

**Template:**
```
5. BUSINESS REQUIREMENTS

BR-001: [Requirement Name]
  Description: [Clear description of the business need]
  Rationale: [Why this is needed]
  Priority: [Critical/High/Medium/Low]
  Stakeholder: [Key stakeholders]
  Status: [Draft/Approved/Review]

BR-002: [Requirement Name]
  Description: [Clear description of the business need]
  Rationale: [Why this is needed]
  Priority: [Critical/High/Medium/Low]
  Stakeholder: [Key stakeholders]
  Status: [Draft/Approved/Review]

[Continue for all business requirements]
```

### Section 6: Functional Requirements (FRs)

**Template:**
```
6. FUNCTIONAL REQUIREMENTS

6.1 [Functional Area 1: e.g., Patient Scheduling]

FR-001.1: [Requirement]
  Description: [Detailed description]
  Acceptance Criteria:
  - [Criterion 1]
  - [Criterion 2]
  - [Criterion 3]
  Priority: [Critical/High/Medium/Low]
  Source: [Stakeholder/Group]
  Status: [Draft/Approved/Review]

FR-001.2: [Requirement]
  Description: [Detailed description]
  Acceptance Criteria:
  - [Criterion 1]
  - [Criterion 2]
  - [Criterion 3]
  Priority: [Critical/High/Medium/Low]
  Source: [Stakeholder/Group]
  Status: [Draft/Approved/Review]

6.2 [Functional Area 2: e.g., Clinical Documentation]

[Continue with requirements]

6.3 [Functional Area 3: e.g., Billing and Revenue Cycle]

[Continue with requirements]
```

### Section 7: Non-Functional Requirements (NFRs)

**Template:**
```
7. NON-FUNCTIONAL REQUIREMENTS

7.1 Performance
NFR-001: [Performance requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.2 Security
NFR-002: [Security requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.3 Availability
NFR-003: [Availability requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.4 Scalability
NFR-004: [Scalability requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.5 Usability
NFR-005: [Usability requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.6 Maintainability
NFR-006: [Maintainability requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.7 Integrability
NFR-007: [Integration requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]

7.8 Compliance
NFR-008: [Compliance requirement]
  Description: [Detailed description]
  Test Criteria: [How to measure/verify]
  Priority: [Critical/High/Medium/Low]
```

### Section 8: Business Rules

**Template:**
```
8. BUSINESS RULES

BR-001: [Business Rule Name]
  Description: [Clear description of the rule]
  Category: [Policy/Operational/Strategic]
  Status: [Approved/Under Review/Proposed]

BR-002: [Business Rule Name]
  Description: [Clear description of the rule]
  Category: [Policy/Operational/Strategic]
  Status: [Approved/Under Review/Proposed]

[Continue for all business rules]
```

### Section 9: Constraints and Assumptions

**Template:**
```
9. CONSTRAINTS AND ASSUMPTIONS

9.1 Constraints
| ID | Constraint | Category | Impact |
|----|------------|----------|--------|
| C-001 | [Constraint] | [Category] | [Impact] |
| C-002 | [Constraint] | [Category] | [Impact] |

9.2 Assumptions
| ID | Assumption | Owner | Impact if False |
|----|------------|-------|-----------------|
| A-001 | [Assumption] | [Owner] | [Impact] |
| A-002 | [Assumption] | [Owner] | [Impact] |
```

### Section 10: Dependencies

**Template:**
```
10. DEPENDENCIES

| ID | Dependency | Type | Impact |
|----|------------|------|--------|
| D-001 | [Dependency] | Internal/External | [Impact] |
| D-002 | [Dependency] | Internal/External | [Impact] |
```

### Section 11: Transition Requirements

**Template:**
```
11. TRANSITION REQUIREMENTS

TR-001: [Transition Requirement]
  Description: [Description]
  Timeline: [When needed]
  Owner: [Who is responsible]

TR-002: [Transition Requirement]
  Description: [Description]
  Timeline: [When needed]
  Owner: [Who is responsible]

[Continue for all transition requirements]
```

### Section 12: Glossary

**Template:**
```
12. GLOSSARY

| Term | Definition |
|------|------------|
| [Term 1] | [Definition] |
| [Term 2] | [Definition] |
| [Term 3] | [Definition] |

[Continue for all terms]
```

### Section 13: Appendix

**Template:**
```
13. APPENDIX

13.1 Supporting Documents
- [Document 1]
- [Document 2]
- [Document 3]

13.2 Process Maps
[Reference to process maps]

13.3 Data Models
[Reference to data models]

13.4 Other Supporting Materials
[Reference to other materials]
```

### Approval Section

**Template:**
```
APPROVAL

By signing below, stakeholders acknowledge that they have reviewed this Business
Requirements Document and agree that it accurately reflects the business needs
for this project.

[Insert approval signatures and dates]
```

---

## 6.3 Agile Requirements Artifacts

### Epics, Features, Themes, and User Stories

**The Agile Requirements Hierarchy:**

```
THEMES (Large Strategic Goals)
    ↓
EPICS (Large Features spanning multiple sprints)
    ↓
FEATURES (Capabilities delivered in a sprint or few sprints)
    ↓
USER STORIES (Specific functionality)
    ↓
ACCEPTANCE CRITERIA (Conditions of satisfaction)
    ↓
TASKS (Development work)
```

### Theme Definition

**Theme:** A high-level strategic goal or category that organizes multiple epics and features.

**MediConnect Themes:**

```
THEME: Patient Experience
  Description: All capabilities that improve the patient's interaction
  with MediConnect, from booking to post-visit follow-up.

THEME: Clinical Excellence
  Description: All capabilities that support clinicians in providing
  high-quality, efficient patient care.

THEME: Operational Efficiency
  Description: All capabilities that improve internal operations,
  reduce costs, and enhance productivity.

THEME: Technology Modernization
  Description: All capabilities that modernize the technology
  infrastructure and reduce technical debt.
```

### Epic Definition

**Epic:** A large body of work that can be broken down into smaller user stories. An epic typically takes multiple sprints to complete.

**MediConnect Epics:**

```
EPIC: Patient Scheduling
  Theme: Patient Experience
  Description: Enable patients to schedule, reschedule, and cancel
  appointments through multiple channels (online, mobile, phone).
  Size: Large
  Epics: 5-10 stories

EPIC: Clinical Documentation
  Theme: Clinical Excellence
  Description: Comprehensive electronic health record capabilities
  enabling efficient clinical documentation.
  Size: Large
  Epics: 8-12 stories

EPIC: Billing and Revenue Cycle
  Theme: Operational Efficiency
  Description: End-to-end billing and revenue cycle management.
  Size: Large
  Epics: 6-8 stories

EPIC: Integration Framework
  Theme: Technology Modernization
  Description: Integration capabilities to connect all systems.
  Size: Large
  Epics: 4-6 stories
```

### Feature Definition

**Feature:** A distinct capability that provides value and can be delivered in a single sprint (or a few sprints).

**MediConnect Features:**

```
FEATURE: Online Appointment Booking
  Epic: Patient Scheduling
  Description: Patients can find available appointment slots and book
  online through the website or mobile app.
  Stories: 3-4 stories

FEATURE: Appointment Reminders
  Epic: Patient Scheduling
  Description: Automated reminders sent via email and SMS 24 hours
  before appointments.
  Stories: 2-3 stories

FEATURE: Comprehensive Patient View
  Epic: Clinical Documentation
  Description: Clinicians can see all patient data in a single,
  unified view.
  Stories: 4-5 stories

FEATURE: Electronic Medical Records
  Epic: Clinical Documentation
  Description: Complete capture and management of clinical data.
  Stories: 5-6 stories
```

### User Story Definition

**User Story:** A small, independently testable piece of functionality that delivers value.

**MediConnect User Stories:**

```
STORY: Book Appointment Online
  Feature: Online Appointment Booking
  As a patient,
  I want to book an appointment online,
  So that I can schedule care without calling.

  Acceptance Criteria:
  1. Search for appointments by:
     - Date
     - Provider
     - Clinic
  2. View available slots with provider and location
  3. Select time and confirm
  4. Receive confirmation with date, time, provider, location
  5. Receive option to add to personal calendar
  Estimation: 5 story points
  Priority: Must Have

STORY: View Patient Medical History
  Feature: Comprehensive Patient View
  As a clinician,
  I want to view a patient's complete medical history,
  So that I can make informed clinical decisions.

  Acceptance Criteria:
  1. View includes:
     - Demographics
     - Medications
     - Allergies
     - Past visits
     - Lab results
     - Imaging results
  2. Data organized chronologically
  3. Search and filter capabilities
  4. Load time < 2 seconds
  Estimation: 8 story points
  Priority: Must Have

STORY: Send Appointment Reminder
  Feature: Appointment Reminders
  As a patient,
  I want to receive a reminder about upcoming appointments,
  So that I don't forget my scheduled care.

  Acceptance Criteria:
  1. Reminder sent 24 hours before appointment
  2. Channel: Email and/or SMS (patient preference)
  3. Message includes: date, time, location, provider
  4. Option to confirm, reschedule, or cancel
  5. Confirmation updates the system
  Estimation: 3 story points
  Priority: Should Have
```

---

## 6.4 Use Cases

### Use Case Overview

**Use Case:** A description of a specific interaction between a user (actor) and the system, detailing the steps to achieve a goal.

**Components:**
- **Actor:** Who interacts with the system
- **Preconditions:** What must be true before the use case starts
- **Basic Flow:** The happy path (success scenario)
- **Alternate Flows:** Other paths (errors, exceptions)
- **Postconditions:** What must be true after the use case completes

### Complete Use Case Specification

**MediConnect Use Case:**

```
USE CASE: Schedule Appointment

| Field | Value |
|-------|-------|
| **Use Case ID** | UC-001 |
| **Use Case Name** | Schedule Appointment |
| **Created By** | [BA Name] |
| **Date Created** | [Date] |
| **Actors** | Patient, Patient Service Representative |
| **Description** | Patient schedules an appointment with a provider |
| **Preconditions** | Patient is registered in system |
| **Postconditions** | Appointment is booked; confirmation is sent; provider schedule is updated |

| BASIC FLOW | STEP | DETAILS |
|------------|------|---------|
| Step 1 | Initiate | Patient or representative initiates scheduling |
| Step 2 | Provide Search Criteria | Patient provides date range, clinic, or provider preference |
| Step 3 | Search Availability | System searches for available appointments matching criteria |
| Step 4 | Display Results | System displays available time slots with provider details |
| Step 5 | Select Appointment | Patient selects preferred time slot |
| Step 6 | Confirm Details | System displays appointment details for confirmation |
| Step 7 | Finalize Appointment | Patient confirms; system books the appointment |
| Step 8 | Send Confirmation | System sends confirmation via email/SMS |
| Step 9 | Update Schedule | System updates provider and resource schedules |

| ALTERNATE FLOWS | DETAILS |
|-----------------|---------|
| **A1: No Availability Found** | No slots matching criteria; offer alternative dates/providers |
| **A2: Patient Not Registered** | Prompt to create account before scheduling |
| **A3: Incomplete Information** | Prompt for missing required information |
| **A4: Appointment Cancelled** | Patient cancels during the process |
| **A5: Insurance Not Verified** | Prompt for insurance information |

| EXCEPTIONS | DETAILS |
|------------|---------|
| **E1: System Unavailable** | Display error message; offer alternative channels |
| **E2: Provider Schedule Changed** | Verify availability before booking |
| **E3: Timeout/Expired Session** | Save partial information; allow to continue later |

| BUSINESS RULES | DETAILS |
|----------------|---------|
| **BR-001** | Appointment must be at least 24 hours in advance (new patients) |
| **BR-002** | Urgent appointments can be same day |
| **BR-003** | Insurance verification required before service |
| **BR-004** | Multiple appointments cannot be booked at same time |
| **BR-005** | Patients must confirm within 30 minutes or slot releases |

| PRIORITY | Critical |
| FREQUENCY | Very High (multiple times daily) |
| RISK | High (patient experience, resource utilization) |

| NOTES | [Additional notes for developers] |
```

### Use Case Diagram

**Use Case Diagram Elements:**
- **Actor:** Stick figure (person/entity)
- **Use Case:** Oval (specific functionality)
- **System Boundary:** Rectangle around use cases
- **Relationships:** Lines connecting actors to use cases

**Use Case Diagram for MediConnect:**

```
┌──────────────────────────────────────────────────────────────┐
│                  MediConnect System                          │
│                                                              │
│    ┌─────────┐          ┌─────────────┐                     │
│    │ Patient  │─────────│    Book     │                     │
│    │  (Actor) │          │ Appointment │                     │
│    └─────────┘          └─────────────┘                     │
│         │               ┌─────────────┐                     │
│         ├───────────────│   Manage    │                     │
│         │               │  Appointments│                     │
│         │               └─────────────┘                     │
│         │               ┌─────────────┐                     │
│         ├───────────────│   View     │                     │
│         │               │   Records  │                     │
│         │               └─────────────┘                     │
│         │               ┌─────────────┐                     │
│         └───────────────│  Send      │                     │
│                         │  Messages  │                     │
│                         └─────────────┘                     │
│                                                              │
│    ┌─────────┐          ┌─────────────┐                     │
│    │Clinician│─────────│  Document   │                     │
│    │ (Actor) │          │   Care      │                     │
│    └─────────┘          └─────────────┘                     │
│         │               ┌─────────────┐                     │
│         ├───────────────│   View     │                     │
│         │               │   Medical  │                     │
│         │               │   History  │                     │
│         │               └─────────────┘                     │
│                                                              │
│    ┌─────────┐          ┌─────────────┐                     │
│    │  Admin  │─────────│  Manage    │                     │
│    │ (Actor) │          │  Schedule  │                     │
│    └─────────┘          └─────────────┘                     │
│         │               ┌─────────────┐                     │
│         ├───────────────│  Process   │                     │
│         │               │  Billing   │                     │
│         │               └─────────────┘                     │
│                                                              │
│    ┌─────────┐          ┌─────────────┐                     │
│    │ System  │─────────│   Generate  │                     │
│    │ (Actor) │          │   Report   │                     │
│    └─────────┘          └─────────────┘                     │
└──────────────────────────────────────────────────────────────┘
```

---

## 6.5 User Journey Maps

### Journey Map Overview

**User Journey Map:** A visual representation of a user's experience with the system, showing their actions, thoughts, emotions, and pain points at each stage.

**Components:**
- **Stages:** Phases of the journey
- **Actions:** What the user does
- **Touchpoints:** System interactions
- **Thoughts:** What the user is thinking
- **Emotions:** How the user feels
- **Pain Points:** Problems encountered
- **Opportunities:** Areas for improvement

### Complete Patient Journey Map

```
PATIENT JOURNEY MAP: MediConnect Patient Experience

STAGE: Awareness & Discovery
  Actions: 
    - Searches online for healthcare providers
    - Reviews MediConnect website
    - Reads patient reviews
    - Asks friends/family for recommendations
  Touchpoints:
    - Website
    - Reviews (Google, Healthgrades)
    - Social media
  Thoughts:
    - "Is this a good provider?"
    - "Do they take my insurance?"
    - "What are the hours?"
  Emotions:
    - Curious
    - Anxious about quality
    - Hopeful
  Pain Points:
    - Website unclear about insurance coverage
    - Can't find provider bios
    - No online scheduling visible
  Opportunities:
    - Clear website with clinic info
    - Provider bios with patient testimonials
    - Direct "Book Online" call-to-action
    - Insurance verification visible

STAGE: Decision & Scheduling
  Actions:
    - Decides to book appointment
    - Calls office during business hours
    - Holds for availability
    - Provides personal information
    - Schedules appointment
  Touchpoints:
    - Phone
    - (Ideally) Online scheduling
  Thoughts:
    - "This is taking too long"
    - "I hope they have availability"
    - "Will this fit my schedule?"
  Emotions:
    - Frustrated (if on hold)
    - Satisfied (if easy)
    - Impatient (if waiting)
  Pain Points:
    - Long hold times
    - Limited scheduling options
    - Phone-only scheduling
    - Can't see availability online
  Opportunities:
    - Online scheduling
    - Show availability in real-time
    - Self-service booking
    - Appointment reminders

STAGE: Pre-Visit Preparation
  Actions:
    - Completes forms (if provided)
    - Gathers insurance card
    - Plans travel to clinic
    - Remembers appointment time
  Touchpoints:
    - Email (confirmation)
    - SMS (reminder)
    - Paper forms
  Thoughts:
    - "What do I need to bring?"
    - "Where is the clinic?"
    - "How long will this take?"
  Emotions:
    - Anxious (about visit)
    - Annoyed (paperwork)
    - Prepared (if informed)
  Pain Points:
    - Forgetting appointment
    - Lost paperwork
    - Traffic/parking issues
    - No reminder option
  Opportunities:
    - Digital forms pre-populated
    - Automated reminders
    - Directions and parking info
    - Prep instructions

STAGE: Check-In & Intake
  Actions:
    - Arrives at clinic
    - Checks in at front desk
    - Shows insurance card
    - Waits for provider
  Touchpoints:
    - Front desk
    - Paper forms
    - Waiting room
  Thoughts:
    - "This is the third time I've given my info"
    - "Why is it taking so long?"
    - "Is the provider on time?"
  Emotions:
    - Impatient
    - Neutral (if smooth)
    - Frustrated (if delayed)
  Pain Points:
    - Re-entering information
    - Long waits
    - No status updates
  Opportunities:
    - Digital check-in kiosk
    - Pre-populated patient data
    - Real-time wait status
    - Mobile check-in

STAGE: Clinical Encounter
  Actions:
    - Medical assistant takes vitals
    - Provider examines
    - Discusses health concerns
    - Provider documents encounter
  Touchpoints:
    - EHR system
    - Medical equipment
    - Patient communication
  Thoughts:
    - "Are they listening?"
    - "How long will this take?"
    - "Can I trust this provider?"
  Emotions:
    - Nervous
    - Relieved (if heard)
    - Valued (if cared for)
  Pain Points:
    - Provider distraction (typing)
    - Rushed consultation
    - Information gaps
  Opportunities:
    - Efficient documentation
    - Face-to-face patient focus
    - AI-assisted documentation
    - Shared decision making

STAGE: Post-Visit Follow-up
  Actions:
    - Receives visit summary
    - Gets instructions
    - Pays bill
    - Schedules follow-up
    - May need further testing
  Touchpoints:
    - Visit summary
    - Billing system
    - Follow-up scheduling
  Thoughts:
    - "Was that helpful?"
    - "I need to remember these instructions"
    - "How much will this cost?"
  Emotions:
    - Clear (if well-informed)
    - Confused (if not)
    - Satisfied (if good experience)
  Pain Points:
    - Unclear instructions
    - Surprise billing
    - Can't access medical records
    - No follow-up guidance
  Opportunities:
    - Patient portal for records
    - Digital visit summary
    - Clear billing explanation
    - Automated follow-up reminders
    - Patient education materials
```

**Your Turn: Create a Journey Map**

Create a journey map for a clinician or administrative staff member:

```
JOURNEY MAP: [Role: Clinician/Admin]

STAGE: [Stage Name]
  Actions:
    - [Action 1]
    - [Action 2]
    - [Action 3]
  Touchpoints:
    - [Touchpoint 1]
    - [Touchpoint 2]
  Thoughts:
    - "[Thought 1]"
    - "[Thought 2]"
  Emotions:
    - [Emotion 1]
    - [Emotion 2]
  Pain Points:
    - [Pain Point 1]
    - [Pain Point 2]
  Opportunities:
    - [Opportunity 1]
    - [Opportunity 2]

[Continue for other stages]
```

---

## 6.6 Decision Tables and Decision Trees

### Decision Tables

**Decision Table:** A structured representation of logical rules that shows conditions and corresponding actions.

**When to Use:**
- Complex business rules
- Multiple conditions
- Many decision paths
- Need for traceability

**Decision Table Template:**

```
DECISION TABLE: Appointment Priority

| CONDITION | Rule 1 | Rule 2 | Rule 3 | Rule 4 | Rule 5 |
|-----------|--------|--------|--------|--------|--------|
| Condition 1: Patient Type | New | Existing | Existing | Existing | New |
| Condition 2: Appointment Type | Urgent | Routine | Urgent | Routine | Urgent |
| Condition 3: Availability | Yes | Yes | Yes | No | No |
| Condition 4: Insurance Verified | Yes | Yes | Yes | Yes | No |
| CONDITION COMBINATION | R1 | R2 | R3 | R4 | R5 |
| ACTION | | | | | |
| Action 1: Book Appointment | ✓ | ✓ | ✓ | | |
| Action 2: Waitlist | | | | ✓ | |
| Action 3: Notify Missing Information | | | | | ✓ |
| Action 4: Provide Alternative Date | | | | ✓ | ✓ |
| Action 5: Urgent Referral | | | ✓ | | |
```

**MediConnect Decision Table Example:**

```
DECISION TABLE: Patient Scheduling Eligibility

| CONDITION | Rule 1 | Rule 2 | Rule 3 | Rule 4 | Rule 5 | Rule 6 |
|-----------|--------|--------|--------|--------|--------|--------|
| Patient registered? | Yes | Yes | Yes | Yes | No | Yes |
| Patient insurance verified? | Yes | Yes | Yes | No | N/A | Yes |
| Patient has PCP assigned? | Yes | Yes | No | Yes | N/A | Yes |
| Appointment type | Routine | Routine | Routine | Routine | Any | Urgent |
| Provider available? | Yes | No | Yes | Yes | N/A | N/A |
| Time until appointment | >24h | >24h | >24h | >24h | Any | <24h |
| CONDITION COMBINATION | R1 | R2 | R3 | R4 | R5 | R6 |
| ACTION | | | | | | |
| Book appointment | ✓ | | | | | |
| Suggest alternative provider | | ✓ | | | | |
| Prompt for PCP assignment | | | ✓ | | | |
| Prompt for insurance verification | | | | ✓ | | |
| Prompt for registration | | | | | ✓ | |
| Urgent care referral | | | | | | ✓ |
```

### Decision Trees

**Decision Tree:** A branching diagram that represents decisions and their possible consequences.

**When to Use:**
- Sequential decisions
- Multiple outcomes
- Need for visual representation
- Stakeholder understanding

**MediConnect Decision Tree Example:**

```
DECISION TREE: Patient Scheduling

                            ┌────────────────┐
                            │ Patient wants  │
                            │ appointment?   │
                            └──────┬─────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
            Yes                   No               Cancels

┌─────────────▼─────────────┐
│ Is patient registered?    │
└─────────────┬─────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
   Yes                 No
    │                   │
┌───▼───┐       ┌───────▼───────┐
│       │       │ Prompt for    │
│  ...  │       │ registration  │
│       │       └───────────────┘
└───────┘
    │
┌───▼───────┐
│ Insurance │
│ verified? │
└───┬───────┘
    │
┌───┴───┐
│       │
Yes     No
│       │
┌───▼───┐ ┌───▼────────────────┐
│       │ │ Prompt insurance   │
│       │ │ verification       │
└───────┘ └────────────────────┘
    │
┌───▼───────┐
│ Provider  │
│ available?│
└───┬───────┘
    │
┌───┴───┐
│       │
Yes     No
│       │
┌───▼───┐ ┌───▼────────────────┐
│ Book  │ │ Suggest alternative│
│ Appt. │ │ dates/providers    │
└───────┘ └────────────────────┘
```

---

## 6.7 Product Backlog

### Complete Product Backlog

The **Product Backlog** is the single source of truth for all work to be done. It is ordered by priority, with the most important items at the top.

**Product Backlog Template:**

```
PRODUCT BACKLOG: MediConnect Integrated Health Platform

Prioritized List (Top to Bottom):

| Priority | ID | Type | Title | Description | Estimate | Value | Risk |
|----------|----|------|-------|-------------|----------|-------|------|
| 1 | E-001 | Epic | Patient Scheduling | Enable patients to schedule appointments online | 50 pts | High | High |
| 2 | S-001 | Story | Book Appointment Online | Patient can book appointment online | 5 pts | High | High |
| 3 | S-002 | Story | View Appointment Availability | Display available slots | 3 pts | High | High |
| 4 | S-003 | Story | Cancel Appointment | Patient can cancel online | 2 pts | Medium | Low |
| 5 | F-001 | Feature | Appointment Reminders | Automate appointment reminders | 10 pts | High | Medium |
| 6 | S-004 | Story | Send Email Reminder | 24-hour email reminder | 3 pts | High | Low |
| 7 | S-005 | Story | Send SMS Reminder | 24-hour SMS reminder | 2 pts | High | Low |
| 8 | E-002 | Epic | Clinical Documentation | Comprehensive EHR capabilities | 80 pts | Critical | High |
| 9 | S-006 | Story | View Patient Medical History | Complete patient view | 8 pts | Critical | High |
| 10 | S-007 | Story | Document Patient Encounter | Capture visit notes | 5 pts | Critical | High |
| 11 | S-008 | Story | Voice-to-Text Documentation | Dictation capability | 8 pts | High | Medium |
| 12 | F-002 | Feature | Lab Result Management | Manage lab results | 10 pts | Medium | Medium |
| 13 | E-003 | Epic | Billing and Revenue | End-to-end billing | 60 pts | High | High |
| 14 | S-009 | Story | Capture Insurance | Insurance info capture | 5 pts | High | High |
| 15 | S-010 | Story | Generate Claims | Claims generation | 8 pts | High | High |
| 16 | S-011 | Story | Process Payments | Payment processing | 5 pts | Medium | Medium |
| 17 | E-004 | Epic | Integration Framework | System integrations | 40 pts | Critical | High |
| 18 | S-012 | Story | EHR Integration | Connect to existing EHR | 13 pts | Critical | High |
| 19 | S-013 | Story | Lab System Integration | Connect to lab systems | 8 pts | High | Medium |
| 20 | S-014 | Story | Billing System Integration | Connect to billing | 5 pts | High | Medium |
| 21 | E-005 | Epic | Patient Portal | Patient self-service | 45 pts | High | Medium |
| 22 | S-015 | Story | View Medical History | View records | 5 pts | High | Low |
| 23 | S-016 | Story | View Test Results | View results | 5 pts | High | Low |
| 24 | S-017 | Story | Send Secure Message | Message providers | 8 pts | Medium | Low |
| 25 | E-006 | Epic | Reporting & Analytics | Reporting capabilities | 30 pts | High | Medium |
| 26 | S-018 | Story | Operational Dashboards | Real-time metrics | 8 pts | High | Medium |
| 27 | S-019 | Story | Patient Satisfaction Report | Satisfaction metrics | 5 pts | High | Low |
| 28 | S-020 | Story | Financial Reports | Financial metrics | 5 pts | High | Low |
| 29 | E-007 | Epic | Security & Compliance | Security features | 40 pts | Critical | High |
| 30 | S-021 | Story | HIPAA Compliance | Regulatory compliance | 13 pts | Critical | High |
| 31 | S-022 | Story | Role-Based Access | Permissions | 8 pts | Critical | High |
| 32 | S-023 | Story | Audit Log | Transaction tracking | 5 pts | High | Medium |

BACKLOG REFINEMENT NOTES:
- Items ordered by value and priority
- Critical items at top
- Next sprint focus: E-001, E-002 (partial)
- Technical debt backlog maintained separately
```

---

## 6.8 Hands-On: Complete Requirements Package

### Your Turn: Create the Complete Requirements Package

**Target:** Build a complete, professional requirements package for MediConnect.

**Package Contents:**

1. **Business Requirements Document (BRD)**
   - All sections completed (1-13)
   - Approved by stakeholders

2. **Product Backlog**
   - Prioritized epics, features, stories
   - Acceptance criteria for each story
   - Estimation and priority

3. **User Story Library**
   - 10+ user stories
   - INVEST compliance
   - Acceptance criteria

4. **Use Case Specifications**
   - 3-5 complete use cases
   - Including basic flow, alternate flows, exceptions

5. **User Journey Maps**
   - At least 2 journey maps
   - Identify pain points and opportunities

6. **Decision Tables/Trees**
   - At least 2 decision tables
   - At least 1 decision tree

7. **Requirements Traceability Matrix**
   - Linking requirements to business needs and stakeholders

### Verification

To verify your requirements package is complete:

1. **Completeness Check:** Is every stakeholder need captured?
2. **Consistency Check:** Are there any conflicts between requirements?
3. **Traceability Check:** Can you trace each requirement to a business need?
4. **Review Check:** Have stakeholders reviewed and approved?
5. **Quality Check:** Are all requirements unambiguous and testable?

---

## 6.9 Check Your Understanding

### Knowledge Check Questions

**1. What is the purpose of a Business Requirements Document?**
```
[Your answer]
```

**2. What are the key components of a BRD?**
```
[Your answer]
```

**3. What is the difference between an epic and a feature?**
```
[Your answer]
```

**4. What are the components of a complete use case?**
```
[Your answer]
```

**5. What is the purpose of a user journey map?**
```
[Your answer]
```

**6. When would you use a decision table vs. a decision tree?**
```
[Your answer]
```

**7. What is the product backlog and how is it ordered?**
```
[Your answer]
```

**8. What is the difference between acceptance criteria and test cases?**
```
[Your answer]
```

**9. What is the purpose of the Requirements Traceability Matrix?**
```
[Your answer]
```

**10. How do you ensure requirements documentation is complete?**
```
[Your answer]
```

---

## 6.10 Summary & Reference

### Key Takeaways from Module 6

✅ The BRD is the primary business requirements document
✅ Agile artifacts include epics, features, themes, and user stories
✅ Use cases capture detailed system interactions
✅ User journey maps visualize the customer experience
✅ Decision tables and trees document complex business logic
✅ The product backlog is the single source of truth for Agile projects
✅ Requirements documentation must balance detail with clarity
✅ Traceability links requirements throughout the lifecycle
✅ Stakeholder review and approval are essential

### Documentation Quick Reference

| Artifact | Purpose | Audience |
|----------|---------|----------|
| BRD | Business requirements | Executives, stakeholders, PMs |
| Functional Spec | Detailed requirements | Developers, QA, technical team |
| Use Cases | Detailed interactions | Developers, QA |
| Product Backlog | All work to be done | Product owners, developers |
| User Stories | Small, testable functionality | Developers, QA |
| User Journey Map | User experience | UX designers, stakeholders |
| Decision Table | Business logic | Developers, business stakeholders |
| RTM | Traceability | QA, regulators, auditors |

### Module Deliverables Checklist

You should have completed these items for your portfolio:

- [ ] Business Requirements Document (BRD) - complete
- [ ] Product Backlog - prioritized
- [ ] User Story Library - 10+ user stories
- [ ] Use Case Specifications - 3-5 use cases
- [ ] User Journey Maps - 2+ journey maps
- [ ] Decision Tables - 2+ decision tables
- [ ] Decision Trees - 1+ decision tree
- [ ] Requirements Traceability Matrix - complete
- [ ] Stakeholder approval documentation

### Recommended Additional Reading

- BABOK® Guide v3, Chapter 7: Requirements Analysis and Design Definition
- "Software Requirements" by Karl Wiegers and Joy Beatty
- "User Stories Applied" by Mike Cohn
- "Writing Effective Use Cases" by Alistair Cockburn
- "The Requirements Engineering Handbook" by Ralph Rowland Young
- "Bridging the Gap Between Business and IT" by Nancy L. Reed
