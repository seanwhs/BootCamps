# Primer 3: The Business Process Modeling Primer

## Visualizing Work to Drive Improvement

---

### Welcome to Business Process Modeling

Business processes are the **heartbeat of any organization**. They are how work gets done—from customer onboarding to product delivery, from patient scheduling to claims processing. But processes are often invisible, undocumented, and inefficient. Business Process Modeling (BPM) makes them visible, understandable, and improvable.

This primer is your practical, hands-on guide to understanding, documenting, and improving business processes. Whether you're a new BA, a process improvement professional, or a stakeholder who wants to understand how work flows, this primer will give you the skills you need.

**This primer is for you if:**
- You need to understand how work actually gets done
- You want to identify inefficiencies and bottlenecks
- You need to communicate processes to stakeholders
- You're preparing for process improvement initiatives
- You're new to BPMN and process modeling

---

## What You'll Learn in This Primer

1. **What business processes are** (and why they matter)
2. **How to discover and document processes** (SIPOC, Value Stream Mapping)
3. **The basics of BPMN 2.0** (the global standard)
4. **How to model simple processes** (step-by-step examples)
5. **How to analyze processes** (As-Is vs. To-Be)
6. **How to identify improvement opportunities**
7. **Common process modeling mistakes** (and how to avoid them)
8. **BPMN quick reference**

---

## 1. What Are Business Processes? (In Plain English)

### The Simple Definition

A **business process** is a series of activities that transforms inputs into outputs that deliver value to a customer.

**In plain English:** A business process is how work gets done—the steps, decisions, and handoffs that turn raw materials (inputs) into finished products or services (outputs).

**The Metaphor:**

Think of a business process like a recipe:
- **Inputs:** Ingredients (raw materials, information, requests)
- **Activities:** Steps in the recipe (mix, chop, cook, assemble)
- **Outputs:** The finished dish (product, service, completed task)
- **Customer:** The person eating the dish (who receives the value)

### Why Processes Matter

| Without Process Visibility | With Process Visibility |
|---------------------------|------------------------|
| Work happens inconsistently | Work is standardized and efficient |
| Bottlenecks are invisible | Bottlenecks are identified and addressed |
| Waste is hidden | Waste is eliminated |
| Improvement is random | Improvement is systematic |
| Knowledge is in people's heads | Knowledge is documented and shared |
| Training is ad hoc | Training is consistent and effective |

### The Process Mindset

**Everything is a process.** Every business activity can be viewed as a process:

- **Patient scheduling:** Request → Search → Book → Confirm
- **Customer order:** Order placed → Processed → Shipped → Delivered
- **Employee onboarding:** Hire → Onboard → Train → Deploy
- **Claims processing:** Claim submitted → Reviewed → Approved/Denied → Paid

**A process transforms:**
```
Inputs → [Activities] → Outputs → Outcomes
```

**Examples:**
| Input | Process | Output | Outcome |
|-------|---------|--------|---------|
| Patient request | Scheduling | Confirmed appointment | Patient satisfaction |
| Customer order | Order processing | Shipped package | Customer loyalty |
| Raw materials | Manufacturing | Finished product | Revenue |

---

## 2. Process Discovery and Documentation

### Step 1: Identify the Process

**Ask these questions:**
1. What is the process we're analyzing?
2. What is the purpose of the process?
3. What are the start and end points?
4. Who is the process owner?
5. Who are the participants?

**Process Identification Template:**
```
PROCESS NAME: [Name]
PURPOSE: [Why does this process exist?]
START: [When does the process begin?]
END: [When does the process end?]
OWNER: [Who is responsible?]
PARTICIPANTS: [Who is involved?]
```

### Step 2: Use SIPOC

**SIPOC** is a high-level process mapping tool that captures:

| Element | Meaning | Example (Patient Scheduling) |
|---------|---------|------------------------------|
| **S**uppliers | Who provides inputs? | Patients, Staff, Insurance |
| **I**nputs | What goes into the process? | Patient data, Appointment request |
| **P**rocess | What steps transform inputs? | Search → Book → Confirm |
| **O**utputs | What comes out? | Confirmed appointment |
| **C**ustomers | Who receives outputs? | Patient, Clinician, Admin |

**SIPOC Template:**
```
SIPOC: [Process Name]

SUPPLIERS:
- [Supplier 1]
- [Supplier 2]
- [Supplier 3]

INPUTS:
- [Input 1]
- [Input 2]
- [Input 3]

PROCESS (High-Level Steps):
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4]
5. [Step 5]

OUTPUTS:
- [Output 1]
- [Output 2]
- [Output 3]

CUSTOMERS:
- [Customer 1]
- [Customer 2]
- [Customer 3]
```

**Example SIPOC: Patient Scheduling**
```
SIPOC: Patient Scheduling

SUPPLIERS:
- Patient
- Front Desk Staff
- Scheduling System

INPUTS:
- Patient appointment request
- Patient data
- Provider availability data
- Room availability data

PROCESS:
1. Patient requests appointment
2. Staff searches availability
3. Patient selects time
4. Staff books appointment
5. System sends confirmation

OUTPUTS:
- Confirmed appointment
- Updated schedule
- Confirmation sent

CUSTOMERS:
- Patient
- Clinician
- Front Desk Staff
```

### Step 3: Use Value Stream Mapping

**Value Stream Mapping (VSM)** visualizes the flow of materials and information, identifying value-added and non-value-added activities.

**Components:**
- **Value-Added Activities:** Steps that directly create value for the customer
- **Non-Value-Added Activities:** Steps that don't add value (waste)
- **Lead Time:** Total time from start to finish
- **Process Time:** Actual work time

**VSM Template:**
```
VALUE STREAM MAP: [Process Name]

| Step # | Process Step | Process Time | Wait Time | Value-Added? | Waste Type | Improvement |
|--------|--------------|--------------|-----------|--------------|------------|-------------|
| 1 | | | | Yes/No | | |
| 2 | | | | Yes/No | | |
| 3 | | | | Yes/No | | |
| 4 | | | | Yes/No | | |
| 5 | | | | Yes/No | | |

SUMMARY:
- Total Lead Time: [Time]
- Total Process Time: [Time]
- Value-Added Percentage: [%]
- Key Improvements: [List]
```

**Example VSM: Patient Scheduling**

| Step | Process Time | Wait Time | Value-Added? | Waste | Improvement |
|------|--------------|-----------|--------------|-------|-------------|
| Patient calls | 5 min | 0 min | No | Waiting | Online booking |
| Patient waits on hold | 0 min | 10 min | No | Waiting | Reduce hold time |
| Staff searches availability | 3 min | 0 min | Yes | - | Speed up search |
| Staff provides options | 2 min | 0 min | Yes | - | Automate options |
| Patient chooses | 2 min | 0 min | Yes | - | - |
| Staff books appointment | 2 min | 0 min | Yes | - | Automate booking |
| System sends confirmation | 1 min | 0 min | Yes | - | - |

**Summary:**
- Total Lead Time: 25 min
- Total Process Time: 15 min
- Value-Added Percentage: 60%
- Key Improvements: Online booking would reduce lead time by 60%

### Step 4: List the 7 Types of Waste

| Waste | Description | Example |
|-------|-------------|---------|
| **Overproduction** | Producing more than needed | Duplicate data entry |
| **Waiting** | Idle time | Patients waiting for providers |
| **Transportation** | Unnecessary movement | Patients sent to multiple departments |
| **Over-processing** | Doing more than needed | Re-entering information |
| **Inventory** | Excess materials | Unused forms, backlogged claims |
| **Motion** | Unnecessary movement of people | Staff walking to find information |
| **Defects** | Errors requiring rework | Data errors, claim denials |

---

## 3. BPMN 2.0 Fundamentals

### What is BPMN?

**BPMN (Business Process Model and Notation)** is the global standard for business process modeling. It provides a common language that bridges business and technical stakeholders.

**Why Use BPMN:**
- Standard notation understood worldwide
- Bridges business and technical stakeholders
- Comprehensive but accessible
- Supports process analysis and improvement
- Tools available for modeling

### BPMN Core Elements

#### 1. Flow Objects

| Element | Symbol | Description | Example |
|---------|--------|-------------|---------|
| **Activity** | Rectangle with rounded corners | Work performed | "Schedule Appointment" |
| **Event** | Circle | Something that happens | "Appointment Requested" |
| **Gateway** | Diamond | Decision point | "Is patient new?" |

#### 2. Connecting Objects

| Element | Symbol | Description | Example |
|---------|--------|-------------|---------|
| **Sequence Flow** | Solid line with arrow | Flow of the process | Connecting activities |
| **Message Flow** | Dashed line with arrow | Communication | Between pools |
| **Association** | Dotted line | Artifact linking | Linking data to activity |

#### 3. Swimlanes

| Element | Symbol | Description | Example |
|---------|--------|-------------|---------|
| **Pool** | Large rectangle | Participant | "Patient" or "Clinic" |
| **Lane** | Within pool | Role | "Front Desk" or "Clinician" |

### BPMN Events

**Start Events (How the process begins):**

| Event | Symbol | Description |
|-------|--------|-------------|
| **None** | Thin circle, no icon | No specific trigger |
| **Message** | Envelope icon | Triggered by a message |
| **Timer** | Clock icon | Triggered by time |
| **Signal** | Flag icon | Triggered by a signal |

**End Events (How the process ends):**

| Event | Symbol | Description |
|-------|--------|-------------|
| **None** | Thick circle | Normal end |
| **Message** | Envelope icon | Sending a message |
| **Terminate** | Solid circle | Stop everything |
| **Error** | Lightning bolt | Error handling |

**Intermediate Events (Occur between start and end):**

| Event | Symbol | Description |
|-------|--------|-------------|
| **Timer** | Clock icon | Wait for time |
| **Message** | Envelope icon | Receive/send message |
| **Error** | Lightning bolt | Handle error |

### BPMN Gateways

| Gateway | Symbol | Description |
|---------|--------|-------------|
| **Exclusive (XOR)** | Diamond with X | Only one path is taken |
| **Inclusive (OR)** | Diamond with circle | One or more paths are taken |
| **Parallel (AND)** | Diamond with plus | All paths are taken simultaneously |
| **Event-Based** | Diamond with circle | Choice based on events |

### BPMN Symbols Quick Reference

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BPMN QUICK REFERENCE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  FLOW OBJECTS                                                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐        │
│  │  ACTIVITY       │  │  EVENT          │  │  GATEWAY        │        │
│  │  (Rounded Rect) │  │  (Circle)       │  │  (Diamond)      │        │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘        │
│                                                                         │
│  CONNECTING OBJECTS                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐        │
│  │  SEQUENCE       │  │  MESSAGE        │  │  ASSOCIATION    │        │
│  │  (Solid arrow)  │  │  (Dashed arrow) │  │  (Dotted line)  │        │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘        │
│                                                                         │
│  SWIMLANES                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                            │
│  │  POOL           │  │  LANE           │                            │
│  │  (Participant)  │  │  (Role)         │                            │
│  └─────────────────┘  └─────────────────┘                            │
│                                                                         │
│  GATEWAYS                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐        │
│  │  EXCLUSIVE (XOR)│  │  INCLUSIVE (OR) │  │  PARALLEL (AND) │        │
│  │  (Diamond, X)   │  │  (Diamond, ○)   │  │  (Diamond, +)   │        │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. How to Model Simple Processes (Step-by-Step)

### Example 1: Simple Appointment Scheduling

**Scenario:** Patient calls to schedule an appointment.

**Step 1: Identify the process**
- Start: Patient needs appointment
- End: Appointment is booked and confirmed

**Step 2: Identify participants**
- Patient (Pool)
- Front Desk (Lane in Clinic Pool)
- System (Lane in Clinic Pool)

**Step 3: Map the sequence**

```
┌─────────────────────────────────────────────────────────────────────────┐
│ PATIENT                 FRONT DESK                   SYSTEM            │
│                         │                            │                 │
│  [Patient Needs        │                            │                 │
│   Appointment]          │                            │                 │
│         │              │                            │                 │
│  [Calls Clinic] ──────>│  [Answers Call]           │                 │
│         │              │         │                  │                 │
│         │              │  [Searches Availability]──>│                 │
│         │              │         │                  │                 │
│         │              │  [Provides Options]        │                 │
│         │              │         │                  │                 │
│<────────│──────────────┼─────────│                  │                 │
│  [Chooses Time]        │         │                  │                 │
│         │              │         │                  │                 │
│────────>│─────────────>│  [Confirms Appointment]──>│                 │
│         │              │         │                  │                 │
│         │              │         │                  │  [Saves          │
│         │              │         │                  │   Appointment]   │
│         │              │         │                  │                 │
│         │              │         │                  │  [Sends          │
│         │              │         │                  │   Confirmation]  │
│         │              │         │                  │                 │
│  [Receives             │         │                  │                 │
│   Confirmation] <──────│─────────│──────────────────│                 │
│         │              │                            │                 │
│  [End]                 │                            │                 │
└─────────────────────────────────────────────────────────────────────────┘
```

### Example 2: Process with Decision (Gateway)

**Scenario:** Patient books appointment online with insurance verification.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ PATIENT                        SYSTEM                                  │
│                                │                                        │
│  [Patient Needs               │                                        │
│   Appointment]                 │                                        │
│         │                      │                                        │
│  [Logs into Portal] ──────────>│  [Display Availability]               │
│         │                      │                                        │
│  [Selects Date/Time] ─────────>│  [Validate Availability]             │
│         │                      │                                        │
│  [Enters Information] ────────>│  [Check Insurance]                   │
│                                │         │                             │
│                                │  ┌──────▼──────┐                      │
│                                │  │  GATEWAY    │                      │
│                                │  │  Verified?  │                      │
│                                │  └──────┬──────┘                      │
│                                │         │                             │
│                                │  ┌──────┴──────┐                      │
│                                │  │             │                      │
│                                │[Yes]         [No]                    │
│                                │  │             │                      │
│  [Confirmation] <─────────────│  │  [Book      │  [Request            │
│         │                      │  │   Appointment]  │   Insurance]     │
│         │                      │  │             │                      │
│  [End]                         │  │  [Send      │  [End: Unable to    │
│                                │  │   Confirmation] │     Book]        │
│                                │  │             │                      │
│                                │  [End:        │                      │
│                                │   Appointment  │                      │
│                                │   Booked]     │                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 5. How to Analyze Processes (As-Is vs. To-Be)

### What is As-Is Analysis?

**As-Is** analysis documents the current state of a process—how it actually works today.

**Why Analyze As-Is:**
- Understand reality (vs. perception)
- Identify pain points and waste
- Establish baseline for improvement
- Build stakeholder consensus

**As-Is Analysis Template:**
```
AS-IS PROCESS ANALYSIS

PROCESS NAME: [Name]
DATE: [Date]
ANALYST: [Name]

1. PROCESS OVERVIEW
   - Purpose: [Why this process exists]
   - Owner: [Who is responsible]
   - Participants: [Who is involved]
   - Start Event: [When it begins]
   - End Event: [When it ends]

2. PROCESS FLOW
   [BPMN diagram or detailed description]

3. PAIN POINTS
   1. [Pain point 1]
   2. [Pain point 2]
   3. [Pain point 3]

4. WASTE IDENTIFIED
   - [Waste type 1]: [Description]
   - [Waste type 2]: [Description]

5. BOTTLENECKS
   - [Bottleneck 1]: [Description]
   - [Bottleneck 2]: [Description]

6. METRICS
   - Cycle Time: [Time]
   - Throughput: [Count/time]
   - Error Rate: [%]
   - Cost: [Amount]
```

### What is To-Be Analysis?

**To-Be** analysis designs the future state—how the process should work.

**Why Design To-Be:**
- Define the ideal process
- Incorporate improvements
- Set a target for change
- Guide implementation

**To-Be Analysis Template:**
```
TO-BE PROCESS DESIGN

PROCESS NAME: [Name]
DATE: [Date]
ANALYST: [Name]

1. PROCESS OVERVIEW
   - Purpose: [Why this process exists]
   - Owner: [Who is responsible]
   - Participants: [Who is involved]
   - Start Event: [When it begins]
   - End Event: [When it ends]

2. PROCESS FLOW
   [BPMN diagram or detailed description]

3. IMPROVEMENTS
   1. [Improvement 1] - [Benefit]
   2. [Improvement 2] - [Benefit]
   3. [Improvement 3] - [Benefit]

4. ELIMINATED WASTE
   - [Waste type 1] eliminated by [improvement]
   - [Waste type 2] eliminated by [improvement]

5. TARGET METRICS
   - Cycle Time: [Time] (improvement from [baseline])
   - Throughput: [Count/time] (improvement from [baseline])
   - Error Rate: [%] (improvement from [baseline])
   - Cost: [Amount] (reduction from [baseline])

6. IMPLEMENTATION APPROACH
   - Phases: [How to implement]
   - Timeline: [When]
   - Resources: [What's needed]
   - Risks: [What could go wrong]
```

### Example: As-Is vs. To-Be Patient Scheduling

**As-Is (Current State):**
- Patient calls clinic
- Staff searches availability across multiple systems
- Staff provides options to patient
- Patient chooses a time
- Staff books appointment
- Staff sends confirmation (sometimes)
- Total time: 20-30 minutes
- Error rate: 8%

**To-Be (Future State):**
- Patient logs into portal/app
- System automatically displays availability
- Patient selects a time
- System automatically books appointment
- System automatically sends confirmation
- Total time: 3-5 minutes
- Error rate: <1%

**Improvements:**
- Online booking eliminates phone call
- Automated search reduces staff time
- Self-service empowers patients
- Automated confirmation improves reliability

---

## 6. How to Identify Improvement Opportunities

### The Improvement Framework

```
1. OBSERVE
   ↓
   Watch the current process in action

2. ANALYZE
   ↓
   Identify pain points and bottlenecks

3. IDEATE
   ↓
   Brainstorm improvement options

4. EVALUATE
   ↓
   Assess feasibility and impact

5. PRIORITIZE
   ↓
   Choose the best improvements

6. IMPLEMENT
   ↓
   Make the changes

7. MEASURE
   ↓
   Verify the improvements worked
```

### Common Improvement Opportunities

| Area | Opportunity | Example |
|------|-------------|---------|
| **Automation** | Automate manual tasks | Online scheduling, automated reminders |
| **Elimination** | Remove unnecessary steps | Eliminate duplicate data entry |
| **Integration** | Connect systems | Single view of patient data |
| **Self-Service** | Empower users | Patient portal, self-check-in |
| **Standardization** | Consistent processes | Standardized scheduling across clinics |
| **Communication** | Better handoffs | Automated notifications, alerts |
| **Error Prevention** | Reduce errors | Validation, decision support |

### Bottleneck Analysis

**Steps to Identify Bottlenecks:**
1. Map the process flow
2. Identify where work accumulates
3. Measure wait times at each step
4. Identify the step with the longest wait
5. Determine why it's bottlenecked
6. Find a solution

**Example Bottleneck Analysis:**

| Process Step | Current State | Wait Time | Bottleneck? | Solution |
|--------------|---------------|-----------|-------------|----------|
| Scheduling search | Manual across 3 systems | 10 min | Yes | Unified search |
| Check-in | Paper forms, manual entry | 5 min | No | Digital check-in |
| Insurance verification | Manual, per visit | 8 min | Yes | Automated verification |
| Documentation | Manual, multiple systems | 15 min | Yes | Integrated EHR |

### Lean Principles for Process Improvement

| Principle | Application |
|-----------|-------------|
| **Eliminate Waste** | Remove non-value-added activities |
| **Optimize Flow** | Reduce bottlenecks and handoffs |
| **Standardize** | Create consistent processes |
| **Pull** | Let demand drive work |
| **Perfect** | Continuous improvement |

---

## 7. Common Process Modeling Mistakes (And How to Avoid Them)

### Mistake 1: Modeling What People Think Happens

**The Problem:**
> People describe the "official" process, not the actual process.

**The Solution:**
> Observe the process. Talk to people doing the work. Find the workarounds.

**How to Avoid:**
- Shadow workers
- Ask "What do you actually do?"
- Watch for workarounds

### Mistake 2: Too Much Detail Too Early

**The Problem:**
> Starting with excessive detail before understanding the big picture.

**The Solution:**
> Start at a high level (SIPOC). Add detail as needed.

**How to Avoid:**
- Start with SIPOC
- Use levels of detail (0, 1, 2)
- Add detail only where needed

### Mistake 3: Over-Complicating the Diagram

**The Problem:**
> Using every BPMN element, resulting in confusion.

**The Solution:**
> Use only what you need. Simple is better.

**How to Avoid:**
- Use core elements first
- Add advanced elements only when needed
- Keep diagrams readable

### Mistake 4: Not Validating with Stakeholders

**The Problem:**
> You model the process, but stakeholders don't agree.

**The Solution:**
> Walk through the model with stakeholders. Get confirmation.

**How to Avoid:**
- Show the model to stakeholders
- Ask "Is this right?"
- Incorporate feedback

### Mistake 5: Forgetting Swimlanes

**The Problem:**
> The model shows what happens, but not who does it.

**The Solution:**
> Use swimlanes to show ownership.

**How to Avoid:**
- Always use swimlanes
- Show handoffs clearly
- Identify ownership

### Mistake 6: Modeling Solutions, Not Processes

**The Problem:**
> Modeling a specific technology solution, not the business process.

**The Solution:**
> Model the business process independent of technology.

**How to Avoid:**
- Focus on what (not how)
- Document business steps, not system steps
- Separate process from implementation

---

## 8. BPMN Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BPMN QUICK REFERENCE CARD                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  FLOW OBJECTS                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ACTIVITY               EVENT                GATEWAY            │   │
│  │  ┌───────────┐          (O)                   ◇               │   │
│  │  │  Task     │          Start: (O)           XOR: ◇ with X    │   │
│  │  └───────────┘          End: (O) thick      OR: ◇ with ○     │   │
│  │  Sub-process:           Intermediate: (O)    AND: ◇ with +    │   │
│  │  ┌───────────┐          double               Event: ◇ with ○  │   │
│  │  │  +        │                                                  │   │
│  │  └───────────┘                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  CONNECTING OBJECTS                                                    │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SEQUENCE FLOW         MESSAGE FLOW          ASSOCIATION       │   │
│  │  ────→                  - - - →              · · ·            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  SWIMLANES                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  POOL (Participant)          LANE (Role)                       │   │
│  │  ┌──────────────────────────┐  ┌───────────┐                  │   │
│  │  │  Clinic                  │  │ Front Desk│                  │   │
│  │  │  ┌───────────┐           │  └───────────┘                  │   │
│  │  │  │           │           │  ┌───────────┐                  │   │
│  │  │  └───────────┘           │  │ Clinician │                  │   │
│  │  └──────────────────────────┘  └───────────┘                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  COMMON PATTERNS                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SEQUENTIAL: Task A → Task B → Task C                          │   │
│  │  DECISION: Task → XOR → Task (Yes) / Task (No)                │   │
│  │  PARALLEL: Task → AND → Task A / Task B → AND → Task         │   │
│  │  LOOP: Task → XOR → Task (Continue) / End (Complete)          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Process Modeling Vocabulary (Key Terms)

| Term | Definition |
|------|------------|
| **Business Process** | Series of activities transforming inputs to outputs |
| **SIPOC** | Suppliers, Inputs, Process, Outputs, Customers |
| **Value Stream** | All steps (value-added and non-value-added) |
| **Waste** | Non-value-added activities |
| **BPMN** | Business Process Model and Notation |
| **Activity** | Work performed in a process |
| **Event** | Something that happens in a process |
| **Gateway** | Decision point in a process |
| **Swimlane** | Visual showing who does what |
| **Pool** | Participant in a process |
| **Lane** | Role within a pool |
| **As-Is** | Current state of a process |
| **To-Be** | Future state of a process |
| **Bottleneck** | Step limiting throughput |
| **Workaround** | Informal way of getting work done |
| **Cycle Time** | Time to complete one cycle |
| **Lead Time** | Total time from start to finish |
| **Throughput** | Amount completed per time period |

---

## 10. Your Process Modeling Toolkit

### Tool 1: SIPOC Template

```
SIPOC: [Process Name]

SUPPLIERS:
- [Supplier 1]
- [Supplier 2]

INPUTS:
- [Input 1]
- [Input 2]

PROCESS:
1. [Step 1]
2. [Step 2]
3. [Step 3]

OUTPUTS:
- [Output 1]
- [Output 2]

CUSTOMERS:
- [Customer 1]
- [Customer 2]
```

### Tool 2: Value Stream Map Template

```
VALUE STREAM MAP: [Process Name]

| Step | Process Time | Wait Time | Value-Added? | Improvement |
|------|--------------|-----------|--------------|-------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

SUMMARY:
- Lead Time:
- Process Time:
- Value-Added %:
- Improvements:
```

### Tool 3: As-Is Analysis Template

```
AS-IS PROCESS ANALYSIS

PROCESS NAME: [Name]
OWNER: [Name]
DATE: [Date]

PAIN POINTS:
1.
2.
3.

WASTE IDENTIFIED:
1.
2.

BOTTLENECKS:
1.
2.

METRICS:
- Cycle Time:
- Error Rate:
- Cost:
```

### Tool 4: To-Be Analysis Template

```
TO-BE PROCESS DESIGN

PROCESS NAME: [Name]
OWNER: [Name]
DATE: [Date]

IMPROVEMENTS:
1. [Improvement] - [Benefit]
2. [Improvement] - [Benefit]

TARGET METRICS:
- Cycle Time: [Target] (from [Baseline])
- Error Rate: [Target] (from [Baseline])
- Cost: [Target] (from [Baseline])

IMPLEMENTATION:
- Phases:
- Timeline:
- Resources:
```

---

## What's Next?

Now that you've completed this primer, you're ready to:

1. **Model a simple process** from your work or daily life
2. **Analyze an As-Is process** and identify improvements
3. **Design a To-Be process** with measurable improvements
4. **Apply these skills** in the Master Business Analysis Series
5. **Try the case studies** in Appendix B

---

**END OF PRIMER 3**

*This primer is your practical guide to business process modeling—making work visible, understandable, and improvable. Keep it handy as you analyze and improve processes in your organization.*

