# Part 2 – Requirements Engineering & Business Discovery

## Module 4: Requirements Elicitation

---

### Learning Objectives

By the end of this module, you will be able to:

- Define requirements elicitation and differentiate it from other BA activities
- Select appropriate elicitation techniques for different situations
- Prepare for and conduct professional stakeholder interviews
- Design and facilitate effective requirements workshops
- Apply advanced techniques like Story Mapping and Event Storming
- Document elicitation results effectively
- Produce a complete Elicitation Plan and supporting artifacts

---

## 4.1 Core Concepts: What is Elicitation?

### The Problem with "Gathering" Requirements

Many people say BAs "gather" requirements. This is a dangerous misconception.

**"Gathering" implies:**
- Requirements are just sitting there waiting to be collected
- It's a passive activity
- What stakeholders say is exactly what they need
- Requirements are complete the first time

**"Elicitation" means:**
- Requirements must be actively drawn out
- It's a collaborative, dynamic process
- What stakeholders say ≠ what they need
- Requirements evolve through exploration

**The Elicitation Reality:**

```
What Stakeholders Say
        ↓
    [Interpretation Filter]
        ↓
What Stakeholders Actually Need
        ↓
    [Context & Constraints]
        ↓
What is Feasible to Build
        ↓
    [Requirements Elicitation & Analysis]
        ↓
What the Solution Should Deliver
```

**Analogy:** If you ask someone, "What do you want to eat?" they might say "Pizza." But what they actually want is "something warm, fast, and satisfying." And what you can deliver depends on what's in the kitchen. Elicitation is the process of understanding the true need (something warm, fast, satisfying), not just the surface request (pizza).

### The Elicitation Mindset

**Key Principles:**

1. **Assume You Don't Know Everything**
   - Curiosity is your greatest tool
   - Every stakeholder has unique perspective

2. **Listen for the Problem, Not the Solution**
   - Stakeholders often propose solutions
   - Your job: understand why they want that solution

3. **Ask "Why" Repeatedly**
   - Surface-level requests hide deeper needs
   - 5 Whys technique applies here too

4. **Triangulate from Multiple Sources**
   - No single stakeholder is fully correct
   - Cross-reference perspectives

5. **Embrace Silence**
   - People need time to think
   - Don't fill the silence too quickly

6. **Be Aware of Your Biases**
   - You have assumptions too
   - Check your preconceptions at the door

7. **Document Everything**
   - You can't remember it all
   - Capture as you go

### Elicitation vs. Analysis vs. Documentation

| Activity | Definition | When It Happens |
|----------|------------|-----------------|
| **Elicitation** | Gathering information from stakeholders | Throughout the project |
| **Analysis** | Structuring and interpreting the information | After/during elicitation |
| **Documentation** | Recording the results | Throughout and after |

**These are iterative, not sequential.** You'll elicit, analyze, document, and then elicit more based on what you learned.

---

## 4.2 Elicitation Techniques: The Complete Toolkit

### Technique 1: Interviews

**Description:** One-on-one conversations with stakeholders to understand their needs, concerns, and perspectives.

**Best For:**
- Deep understanding of individual perspectives
- Sensitive topics
- Stakeholders who are hard to schedule in groups
- Early discovery
- Subject matter expertise

**Types of Interviews:**

| Type | Description | When to Use |
|------|-------------|-------------|
| **Structured** | Pre-set questions, consistent format | When comparing across stakeholders |
| **Semi-Structured** | Prepared questions but flexibility to probe | Most common and effective |
| **Unstructured** | Open conversation, minimal structure | Early exploration; brainstorming |

**Interview Process:**

```
PHASE 1: PLANNING
- Define interview objectives
- Identify the right stakeholders
- Research background information
- Prepare questions (structured/semi-structured)
- Schedule adequate time (45-90 minutes)
- Confirm logistics and expectations

PHASE 2: CONDUCTING
- Establish rapport and set context
- Ask open-ended questions
- Use active listening techniques
- Probe for deeper understanding
- Take detailed notes (or record with permission)
- Watch for non-verbal cues
- Stay on time

PHASE 3: FOLLOW-UP
- Send thank-you note
- Share and verify notes
- Provide summary/action items
- Schedule follow-up if needed
- Update stakeholder register
```

**Sample Interview Guide (Clinical Workflow):**

```
INTERVIEW GUIDE: Clinical Workflow Analysis

Interviewee: [Name], [Title]
Date/Time: [Date], [Time]
Interviewer: [BA Name]
Objective: Understand current clinical workflow and identify improvement opportunities

SECTION 1: CONTEXT
1. "Tell me about your role. What does a typical day look like?"
2. "How long have you been doing this work?"
3. "What parts of your job are most fulfilling? Most frustrating?"

SECTION 2: CURRENT WORKFLOW
4. "Walk me through a typical patient encounter from start to finish."
5. "What systems do you interact with during this process?"
6. "What information do you need that you don't have access to?"
7. "How do you currently coordinate with other staff?"

SECTION 3: PAIN POINTS
8. "What slows you down or frustrates you most?"
9. "Where do errors occur?"
10. "What workarounds have you developed?"
11. "What information is hard to find?"

SECTION 4: DESIRED FUTURE
12. "If you could change one thing, what would it be?"
13. "What would make your job significantly easier?"
14. "How would you describe the ideal system?"
15. "What would help you provide better patient care?"

SECTION 5: ADDITIONAL
16. "Who else should I talk to?"
17. "Is there anything I haven't asked that I should know?"
18. "May I follow up if I have more questions?"

NOTES:
[Detailed notes during interview]

FOLLOW-UP:
[Items to follow up on, confirmations needed]
```

### Technique 2: Workshops

**Description:** Facilitated group sessions where stakeholders collaborate to explore, define, and prioritize requirements.

**Best For:**
- Cross-functional alignment
- Building consensus
- Complex problems
- Requirements prioritization
- Design sprints
- Decision-making

**Workshop Planning Checklist:**

```
WORKSHOP PLANNING CHECKLIST

PRE-WORKSHOP (1-2 weeks before):
[ ] Define workshop objectives and outcomes
[ ] Identify participants (4-15 ideal, 15-30 max)
[ ] Prepare agenda with timing (2-4 hours ideal)
[ ] Develop content and materials
[ ] Send invitations with clear objectives and agenda
[ ] Gather pre-work from participants
[ ] Test logistics (room, equipment, materials)
[ ] Prepare facilitation guide

DURING WORKSHOP:
[ ] Welcome and set context
[ ] Establish ground rules
[ ] Review agenda and objectives
[ ] Lead activities
[ ] Manage group dynamics
[ ] Document outputs (whiteboard, sticky notes, digital)
[ ] Summarize as you go
[ ] Agree on next steps
[ ] Close with clear action items

POST-WORKSHOP (within 48 hours):
[ ] Share outputs and decisions
[ ] Finalize documentation
[ ] Follow up on action items
[ ] Gather feedback on workshop
[ ] Update requirements artifacts
```

**Workshop Types:**

| Type | Purpose | Activities |
|------|---------|------------|
| **Discovery Workshop** | Explore the problem space | Brainstorming, problem definition, stakeholder mapping |
| **Requirements Workshop** | Define and prioritize requirements | Specification, prioritization, consensus building |
| **Design Workshop** | Generate solution ideas | Prototyping, storyboarding, design thinking |
| **Decision Workshop** | Make key decisions | Pros/cons analysis, voting, risk assessment |
| **Retrospective** | Reflect and improve | Lessons learned, continuous improvement |

**Workshop Template:**

```
WORKSHOP PLAN: [Workshop Title]

1. WORKSHOP OVERVIEW
   - Purpose: 
   - Outcomes: 
   - Date/Time: 
   - Duration: 
   - Location: 

2. PARTICIPANTS
   - Stakeholder Group: [List stakeholders]
   - Facilitator: [Name]
   - Note-taker: [Name]

3. AGENDA
   Time | Activity | Duration | Owner
   ------|----------|----------|-------
   9:00 | Welcome & Context | 15 min | Facilitator
   9:15 | Current State Overview | 20 min | [Name]
   9:35 | Pain Points Exercise | 25 min | Facilitator
   10:00 | Break | 10 min | 
   10:10 | Future State Vision | 30 min | Facilitator
   10:40 | Requirements Identification | 30 min | Facilitator
   11:10 | Prioritization Exercise | 25 min | Facilitator
   11:35 | Next Steps & Close | 15 min | Facilitator

4. GROUND RULES
   - One conversation at a time
   - Build on each other's ideas
   - Stay focused on the topic
   - Be respectful of all perspectives
   - Phone and laptop-free zones
   - All ideas are valid (no bad ideas)

5. MATERIALS
   - Whiteboard and markers
   - Sticky notes (various colors)
   - Handouts
   - Laptops for facilitators
   - Projector
   - Recording devices (with permission)
   - Templates for exercises

6. FACILITATION TECHNIQUES
   - Brainstorming: Generate ideas, no judgment
   - Dot voting: Prioritization
   - Affinity grouping: Organize themes
   - Round robin: Ensure all voices heard
   - Parking lot: Capture off-topic ideas
   - Timeboxing: Stay on schedule

7. EXIT CRITERIA
   - Clear understanding of current pain points
   - Agreed future state vision
   - Identified requirements (minimum X)
   - Prioritized backlog
   - Clear action items
```

### Technique 3: Focus Groups

**Description:** Small group discussions (6-10 participants) with stakeholders from similar roles to understand collective perspectives.

**Best For:**
- Understanding common needs across similar roles
- Generating ideas in a safe environment
- Validating assumptions
- Testing concepts

**Focus Group Guide:**

```
FOCUS GROUP GUIDE: Clinician User Experience

Participants: 6-8 physicians from across clinics
Duration: 2 hours
Objective: Understand common clinician frustrations and desired improvements

AGENDA:
0:00-0:15: Introductions and context
0:15-0:30: Individual reflection exercise
0:30-1:00: Group discussion: Pain points
1:00-1:15: Break
1:15-1:45: Group discussion: Ideal workflow
1:45-2:00: Summary and validation

DISCUSSION QUESTIONS:
1. "What aspects of your workflow are most frustrating?"
2. "What workarounds have you developed?"
3. "How do you currently stay organized?"
4. "What would a perfect system allow you to do?"
5. "What concerns do you have about changing the system?"

FACILITATOR NOTES:
- Encourage balanced participation
- Avoid dominant voices
- Keep discussion on track
- Record with permission
- Use flip charts for visibility
```

### Technique 4: Brainstorming

**Description:** Generating ideas in a judgment-free environment, focusing on quantity over quality initially.

**Best For:**
- Generating many ideas quickly
- Breaking out of conventional thinking
- Creative problem-solving
- Innovation sessions

**Brainstorming Rules:**

1. **Defer Judgment** - No criticism of ideas
2. **Encourage Wild Ideas** - Think outside the box
3. **Build on Other Ideas** - "Yes, and..."
4. **Stay Focused on Topic** - Don't go too far off track
5. **One Conversation at a Time** - Respect the speaker
6. **Visualize** - Write everything down
7. **Quantity Over Quality** - The more ideas, the better

**Brainstorming Variations:**

| Variation | Description | When to Use |
|-----------|-------------|-------------|
| **Round Robin** | Each person shares one idea in turn | When some voices are quieter |
| **Brainwriting** | Write ideas individually, then share | For introverted groups |
| **Sticky Note Storm** | Each idea on a sticky note on wall | To see patterns emerge |
| **Reverse Brainstorming** | Brainstorm how to make problems worse, then reverse | Complex problems |

### Technique 5: Observation and Shadowing

**Description:** Watching stakeholders perform their work to understand their actual processes and behaviors.

**Best For:**
- Understanding reality vs. reported processes
- Capturing subtle behaviors people don't mention
- Discovering workarounds
- Validating process maps

**Observation Process:**

1. **Prepare:** Explain purpose, schedule time, get permission
2. **Be Invisible:** Don't interfere with their work
3. **Take Notes:** Capture everything (what, when, how, exceptions)
4. **Ask Questions:** At breaks, clarify what you saw
5. **Look for Patterns:** Repetition, workarounds, pain points
6. **Document:** Create process maps from observations

**Observation Template:**

```
OBSERVATION GUIDE

Observer: [Name]
Subject: [Role/Name]
Date: [Date]
Time: [Start - End]
Location: [Location]

WHAT I OBSERVED:

Process Step | Duration | Observations | Questions
-------------|----------|--------------|----------
[Step 1] | [Time] | [Observations] | [Questions]
[Step 2] | [Time] | [Observations] | [Questions]
[Step 3] | [Time] | [Observations] | [Questions]

PAIN POINTS OBSERVED:
1. [Observation]
2. [Observation]
3. [Observation]

WORKAROUNDS OBSERVED:
1. [Observation]
2. [Observation]

INFORMAL INFORMATION SHARING:
1. [Observation]
2. [Observation]

SURPRISING OBSERVATIONS:
1. [Observation]
2. [Observation]

QUESTIONS TO FOLLOW UP ON:
1. [Question]
2. [Question]
```

### Technique 6: Surveys and Questionnaires

**Description:** Structured instruments to gather information from a large group.

**Best For:**
- Large populations
- Statistical analysis
- When you need to validate findings from other methods
- When stakeholders are geographically dispersed

**Best Practices:**

- **Keep it short:** 10-15 questions max
- **Mix question types:** Multiple choice, scales, open-ended
- **Pilot test:** With a small group first
- **Provide context:** Why are you asking?
- **Ensure anonymity:** For sensitive topics
- **Design for response rate:** Clear purpose, easy completion
- **Communicate results:** Close the feedback loop

### Technique 7: Document Analysis

**Description:** Reviewing existing documentation to understand the current environment.

**Best For:**
- Background research
- Understanding business processes
- Discovering existing requirements
- Identifying gaps

**Documents to Analyze:**

| Document Type | What You Can Learn |
|---------------|-------------------|
| Business Plans | Strategy, goals, priorities |
| Process Documentation | Current workflows, procedures |
| System Documentation | Technical architecture, existing capabilities |
| Policies and Procedures | Rules, constraints |
| Project Documentation | Past projects, lessons learned |
| User Manuals | How systems are used |
| Training Materials | User needs, pain points |
| Reports | Performance metrics, trends |
| Regulatory Documents | Compliance requirements |

**Document Analysis Template:**

```
DOCUMENT ANALYSIS

Document: [Document Name]
Date: [Date]
Author: [Author]
Purpose: [Purpose of document]

KEY FINDINGS:

1. Important Information:
   - [Finding]
   - [Finding]

2. Gaps Identified:
   - [Gap]
   - [Gap]

3. Inconsistencies:
   - [Inconsistency]
   - [Inconsistency]

4. Assumptions:
   - [Assumption]
   - [Assumption]

5. References to Other Documents:
   - [Reference]
   - [Reference]

6. Questions from Document Review:
   - [Question]
   - [Question]

7. Requirements Discovered:
   - [Requirement]
   - [Requirement]

PRIORITY FOLLOW-UP ACTIONS:
1. [Action]
2. [Action]
```

---

## 4.3 Advanced Elicitation Techniques

### Technique 8: Story Mapping

**Description:** A visual exercise that organizes user activities and tasks to understand the full user experience and create a roadmap for development.

**Developed by:** Jeff Patton

**Why Use Story Mapping:**
- Shows the big picture
- Organizes by user goals
- Identifies gaps in user experience
- Helps prioritize features
- Aligns technical and business stakeholders
- Provides a visual roadmap

**Story Mapping Structure:**

```
                    ACTIVITIES (Goals)
                          |
                          |
    ACTIVITY 1        ACTIVITY 2        ACTIVITY 3
        |                |                |
    [Tasks]           [Tasks]           [Tasks]
        |                |                |
    [Sub-tasks]       [Sub-tasks]       [Sub-tasks]
        |                |                |
    [Details]         [Details]         [Details]
```

**Example: Patient Scheduling Story Map**

```
ACTIVITY: Book an Appointment
    TASK: Find Available Time
        SUB-TASK: Search by date
        SUB-TASK: Search by provider
        SUB-TASK: Search by clinic
        SUB-TASK: View provider availability
    TASK: Choose Time
        SUB-TASK: Select preferred date/time
        SUB-TASK: Confirm with patient
    TASK: Provide Patient Info
        SUB-TASK: Enter basic patient info
        SUB-TASK: Confirm existing patient
        SUB-TASK: Verify insurance
    TASK: Confirm Appointment
        SUB-TASK: Send confirmation
        SUB-TASK: Add to calendar
        SUB-TASK: Send reminder preferences

ACTIVITY: Reschedule Appointment
    TASK: Find Existing Appointment
    TASK: View Availability
    TASK: Select New Time
    TASK: Confirm Reschedule
    TASK: Update Notifications

ACTIVITY: Cancel Appointment
    TASK: Find Appointment
    TASK: Process Cancellation
    TASK: Update Availability
    TASK: Notify Provider
```

**Story Mapping Workshop:**

```
STORY MAPPING WORKSHOP PLAN

Purpose: Map the entire patient journey from appointment booking to follow-up
Duration: 4 hours
Participants: 8-10 stakeholders (clinicians, admin, IT, patients)

AGENDA:
0:00-0:30: Introduction and overview
0:30-1:00: Identify main activities (goals)
1:00-1:30: Map tasks for each activity
1:30-2:00: Add sub-tasks and details
2:00-2:30: Walk the journey (check for gaps)
2:30-3:00: Prioritization (MVP vs. future)
3:00-3:30: Identify dependencies and risks
3:30-4:00: Review and next steps

MATERIALS NEEDED:
- Large wall or whiteboard
- Index cards (various colors)
- Markers
- Tape
- Timers

PRIORITIZATION RULES:
- Must Have (First Release): Core functionality
- Should Have (Next Release): Important but not critical
- Could Have (Future): Nice to have
- Won't Have (Out of Scope): Not doing at all
```

**Your Turn: Create a Story Map**

Create a story map for a key process at MediConnect:

```
STORY MAP: [Process Name]

ACTIVITY 1: [Activity Name]
  TASK 1.1: [Task]
    - [Sub-task]
    - [Sub-task]
    - [Sub-task]
  TASK 1.2: [Task]
    - [Sub-task]
    - [Sub-task]

ACTIVITY 2: [Activity Name]
  TASK 2.1: [Task]
    - [Sub-task]
    - [Sub-task]
  TASK 2.2: [Task]
    - [Sub-task]
    - [Sub-task]

PRIORITIZATION:
MUST HAVE (MVP):
- [Task]
- [Task]
- [Task]

SHOULD HAVE:
- [Task]
- [Task]

COULD HAVE:
- [Task]
- [Task]

WON'T HAVE:
- [Task]
- [Task]
```

### Technique 9: Event Storming

**Description:** A collaborative workshop technique to explore complex business processes by mapping events, commands, and domains.

**Developed by:** Alberto Brandolini

**Why Use Event Storming:**
- Visualizes the entire workflow
- Identifies bottlenecks and complexity
- Aligns business and technical understanding
- Identifies missing steps or handoffs
- Facilitates domain-driven design

**Event Storming Language:**

| Symbol | Meaning | Color | Example |
|--------|---------|-------|---------|
| **Event** | Something that happened | Orange | "Patient Scheduled" |
| **Command** | Something someone does | Blue | "Schedule Appointment" |
| **Aggregate** | Entity with state and behavior | Yellow | "Patient" |
| **Policy** | Rule that triggers action | Purple | "Send Reminder 24hrs Before" |
| **External System** | External actor/interface | Pink | "Insurance Verification System" |
| **User Interface** | Screen/UI component | Green | "Appointment Screen" |
| **Read Model** | Projection of data | Green | "Patient Schedule View" |

**Event Storming Process:**

```
EVENT STORMING WORKSHOP

1. IDENTIFY EVENTS (Orange)
   - What happens in the process?
   - Write each event on an orange sticky note
   - Timebox: 15 minutes
   - Example: "Patient Scheduled", "Appointment Confirmed"

2. SEQUENCE EVENTS
   - Arrange events in chronological order
   - Identify missing events
   - Timebox: 10 minutes

3. ADD COMMANDS (Blue)
   - Who initiates each event?
   - What triggers each event?
   - Timebox: 15 minutes
   - Example: "Schedule Appointment" → "Patient Scheduled"

4. ADD AGGREGATES (Yellow)
   - What entities are involved?
   - What has state and behavior?
   - Timebox: 10 minutes
   - Example: Patient, Provider, Schedule, Appointment

5. ADD POLICIES (Purple)
   - What rules trigger actions?
   - What automated behaviors exist?
   - Timebox: 10 minutes
   - Example: "If Appointment is scheduled tomorrow, send reminder"

6. ADD EXTERNAL SYSTEMS (Pink)
   - What external systems interact?
   - Timebox: 5 minutes
   - Example: EHR, Scheduling System, Insurance Provider

7. ADD UI/READ MODELS (Green)
   - What screens or data views are needed?
   - Timebox: 5 minutes
   - Example: "Appointment View", "Provider Schedule"

8. REVIEW AND REFINE
   - Walk through the process
   - Validate with stakeholders
   - Identify gaps and questions
   - Timebox: 20 minutes
```

**Event Storming Example: Patient Scheduling**

```
EVENT STORMING: Patient Scheduling Process

EVENTS (Orange):
1. Patient Identified
2. Patient Verified
3. Appointment Requested
4. Provider Availability Checked
5. Available Times Found
6. Time Slot Selected
7. Insurance Verified
8. Appointment Scheduled
9. Confirmation Sent
10. Reminder Scheduled
11. Reminder Sent
12. Appointment Checked-in
13. Appointment Canceled
14. Appointment Rescheduled

COMMANDS (Blue):
1. Identify Patient → Patient Identified
2. Search Provider Availability → Available Times Found
3. Select Time → Time Slot Selected
4. Verify Insurance → Insurance Verified
5. Schedule Appointment → Appointment Scheduled
6. Send Confirmation → Confirmation Sent
7. Schedule Reminder → Reminder Scheduled

AGGREGATES (Yellow):
1. Patient (Name, DOB, Contact, Insurance, History)
2. Provider (Name, Schedule, Specialization)
3. Schedule (Slots, Availability, Booked)
4. Appointment (Patient, Provider, DateTime, Status)

POLICIES (Purple):
1. "Schedule appointment only if provider available"
2. "Send confirmation automatically after scheduling"
3. "Send reminder 24 hours before appointment"
4. "If date/time unavailable, suggest alternatives"

EXTERNAL SYSTEMS (Pink):
1. Insurance Verification System
2. EHR System
3. Email/SMS Notification System
4. Billing System

UI/READ MODELS (Green):
1. Patient Search
2. Schedule Availability Calendar
3. Appointment Details View
4. Provider Schedule Dashboard
5. Notification History View
```

---

## 4.4 The Elicitation Plan

### Comprehensive Elicitation Plan Template

```
ELICITATION PLAN: [Project Name]

1. ELICITATION OBJECTIVES
   - Objective 1: [What we need to learn]
   - Objective 2: [What we need to learn]
   - Objective 3: [What we need to learn]

2. ELICITATION SCOPE
   - What's In-Scope: [Areas to cover]
   - What's Out-of-Scope: [Areas not to cover]
   - Key Questions to Answer:
     - [Question]
     - [Question]
     - [Question]

3. STAKEHOLDER TARGETS
   - Stakeholder Group 1: [List]
   - Stakeholder Group 2: [List]
   - Stakeholder Group 3: [List]

4. ELICITATION TECHNIQUES
   - Primary Technique(s): [Technique]
   - Supplementary Techniques: [Technique]
   - Rationale: [Why chosen]

5. ELICITATION ACTIVITIES
   Activity 1: [Activity]
     - Type: [Interview/Workshop/Survey/etc.]
     - Stakeholders: [List]
     - Duration: [Time]
     - Date: [Date]
     - Output: [Deliverable]
     - Owner: [Person]

   Activity 2: [Activity]
     - Type: [Interview/Workshop/Survey/etc.]
     - Stakeholders: [List]
     - Duration: [Time]
     - Date: [Date]
     - Output: [Deliverable]
     - Owner: [Person]

   Activity 3: [Activity]
     - Type: [Interview/Workshop/Survey/etc.]
     - Stakeholders: [List]
     - Duration: [Time]
     - Date: [Date]
     - Output: [Deliverable]
     - Owner: [Person]

6. SCHEDULE
   - Phase 1: [Dates] - [Activities]
   - Phase 2: [Dates] - [Activities]
   - Phase 3: [Dates] - [Activities]

7. RESOURCES
   - Human: [Team members]
   - Financial: [Budget]
   - Tools: [Tools needed]
   - Materials: [Materials needed]

8. RISKS
   - Risk 1: [Risk] | Mitigation: [Strategy]
   - Risk 2: [Risk] | Mitigation: [Strategy]
   - Risk 3: [Risk] | Mitigation: [Strategy]

9. SUCCESS METRICS
   - Metric 1: [How to measure success]
   - Metric 2: [How to measure success]
   - Metric 3: [How to measure success]
```

### Your Turn: Create the Elicitation Plan for MediConnect

```
ELICITATION PLAN: MediConnect Integrated Health Platform

1. ELICITATION OBJECTIVES:
- Objective 1: Understand current clinical workflow and pain points
- Objective 2: Define patient scheduling requirements
- Objective 3: Identify clinical documentation needs
- Objective 4: Understand integration requirements with existing systems
- Objective 5: Define patient digital experience expectations
- Objective 6: Identify regulatory and compliance requirements

2. ELICITATION SCOPE:
In-Scope:
- Clinical workflow (scheduling, documentation, care delivery)
- Patient experience (scheduling, communication, portal)
- Billing and revenue cycle requirements
- Integration with existing systems
- Reporting and analytics needs
- Regulatory requirements (HIPAA, privacy)

Out-of-Scope:
- Detailed technical architecture (Phase 3)
- UI design (Phase 3)
- Implementation planning (Phase 5)

Key Questions:
- What are the biggest pain points in the current workflow?
- What are the ideal patient and clinician experiences?
- What are the must-have vs. nice-to-have requirements?
- What integrations are critical?
- What are the regulatory constraints?

3. STAKEHOLDER TARGETS:

Clinical Stakeholders:
- Dr. Michael Rodriguez (CMO)
- Dr. Emily Park (Physician)
- Nurse Thomas Wright (Charge Nurse)
- 3 additional physicians
- 2 additional nurses

Operational Stakeholders:
- David Kim (Operations Director)
- Maria Gonzalez (Practice Manager)
- 2 additional practice managers

Technical Stakeholders:
- Lisa Martin (IT Director)
- Jennifer Lee (Lead Developer)
- Carlos Martinez (QA Lead)

Financial Stakeholders:
- Patricia Okafor (CFO)
- Robert Thompson (Billing Manager)

Leadership:
- Sarah Chen (CEO)

External Stakeholders:
- Tom Baker (Patient Advocate)
- Dr. Karen Wu (Compliance)
- 2 Patient representatives

4. ELICITATION TECHNIQUES:
Primary Techniques:
- Interviews: Individual deep-dives with key stakeholders
- Workshops: Collaborative group sessions
- Observation/Shadowing: Understanding actual workflows

Supplementary Techniques:
- Document Analysis: Review existing systems and processes
- Surveys: Broader input from larger groups

Rationale: Mix of techniques provides deep insight (interviews, observation) and broad input (surveys, workshops), cross-validating findings.

5. ELICITATION ACTIVITIES:

ACTIVITY 1: Clinical Workflow Discovery
- Type: Interviews and Observation
- Stakeholders: Dr. Emily Park, Nurse Thomas Wright, Maria Gonzalez
- Duration: 1-2 hours per interview + 4 hours observation
- Date: Week 1-2
- Output: Clinical Workflow Observations
- Owner: [BA Name]

ACTIVITY 2: Executive Vision Workshop
- Type: Workshop
- Stakeholders: Sarah Chen, Dr. Michael Rodriguez, Patricia Okafor, David Kim
- Duration: 2 hours
- Date: Week 1
- Output: Vision Statement, OKRs
- Owner: [BA Name]

ACTIVITY 3: Patient Scheduling Story Mapping
- Type: Workshop (Story Mapping)
- Stakeholders: Clinical + Operational + Patient Advocate
- Duration: 4 hours
- Date: Week 2
- Output: Story Map, Backlog
- Owner: [BA Name]

ACTIVITY 4: Patient Experience Focus Group
- Type: Focus Group
- Stakeholders: Patients (6-8), Patient Advocate
- Duration: 2 hours
- Date: Week 2
- Output: Patient Experience Requirements
- Owner: [BA Name]

ACTIVITY 5: Technical Integration Workshop
- Type: Workshop (Event Storming)
- Stakeholders: IT Director, Developer, QA, Integration Partners
- Duration: 3 hours
- Date: Week 3
- Output: Integration Requirements
- Owner: [BA Name]

ACTIVITY 6: Regulatory & Compliance Session
- Type: Interview
- Stakeholders: Dr. Karen Wu (Compliance)
- Duration: 1.5 hours
- Date: Week 3
- Output: Compliance Requirements
- Owner: [BA Name]

ACTIVITY 7: Clinician Workflow Event Storming
- Type: Workshop (Event Storming)
- Stakeholders: Clinicians (6), Operations, IT
- Duration: 3 hours
- Date: Week 3
- Output: Workflow Models
- Owner: [BA Name]

ACTIVITY 8: Billing & Finance Requirements
- Type: Interview + Document Analysis
- Stakeholders: Robert Thompson, Patricia Okafor
- Duration: 1.5 hours each
- Date: Week 4
- Output: Billing Requirements
- Owner: [BA Name]

ACTIVITY 9: Current State Process Mapping
- Type: Observation + Document Analysis
- Stakeholders: Operations, Clinical Staff
- Duration: 2-3 days
- Date: Week 2-4
- Output: As-Is Process Models
- Owner: [BA Name]

ACTIVITY 10: Clinician Survey
- Type: Survey
- Stakeholders: All clinicians (50)
- Duration: 15 minutes per respondent
- Date: Week 2
- Output: Survey Results
- Owner: [BA Name]

ACTIVITY 11: Admin Staff Survey
- Type: Survey
- Stakeholders: All administrative staff (30)
- Duration: 15 minutes per respondent
- Date: Week 2
- Output: Survey Results
- Owner: [BA Name]

ACTIVITY 12: Requirements Consolidation Workshop
- Type: Workshop
- Stakeholders: Key stakeholders from all groups
- Duration: 4 hours
- Date: Week 4
- Output: Consolidated Requirements
- Owner: [BA Name]

6. SCHEDULE:
Phase 1 - Discovery: Week 1
- Activities: Vision Workshop, Initial Interviews

Phase 2 - Deep Elicitation: Week 2
- Activities: Story Mapping, Focus Groups, Surveys, Shadowing

Phase 3 - Technical & Compliance: Week 3
- Activities: Event Storming, Integration, Regulatory

Phase 4 - Consolidation: Week 4
- Activities: Billing, Consolidation Workshop, Requirements Validation

7. RESOURCES:
Human: 2 Business Analysts (full-time)
Financial: $0 (internal effort)
Tools: Miro (for virtual workshops), Office Suite, Jira (for backlog)
Materials: Whiteboards, sticky notes, markers, printing

8. RISKS:
Risk 1: Stakeholder availability
  Mitigation: Schedule early; have backup stakeholders
Risk 2: Clinician time constraints
  Mitigation: Shadowing during work hours; short, focused interviews
Risk 3: Resistance to sharing honest feedback
  Mitigation: Ensure confidentiality; create safe spaces
Risk 4: Misalignment on scope
  Mitigation: Clear communication; revisit scope regularly

9. SUCCESS METRICS:
Metric 1: 90%+ stakeholder engagement rate
Metric 2: All planned interviews/workshops completed on schedule
Metric 3: Requirements coverage (all key areas addressed)
Metric 4: Stakeholder satisfaction with elicitation process (survey)
Metric 5: Clear, validated requirements documented
```

---

## 4.5 Elicitation Best Practices

### Do's and Don'ts

**DO:**
- Prepare thoroughly before any elicitation session
- Create a safe environment for honest feedback
- Listen more than you talk
- Ask open-ended questions
- Probe deeper when you sense hidden needs
- Document as you go
- Validate understanding regularly
- Follow up after sessions
- Show appreciation to stakeholders
- Be curious and humble

**DON'T:**
- Jump to solutions too quickly
- Accept surface-level answers at face value
- Use jargon or technical language excessively
- Make assumptions without validation
- Ask leading questions
- Dominate the conversation
- Dismiss concerns or criticisms
- Delay documenting what you heard
- Share sensitive information inappropriately
- Go into a session unprepared

### Common Elicitation Mistakes and How to Avoid Them

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| **Asking Only "What Do You Want?"** | Focus on solution | Ask about problems, goals, frustrations first |
| **Accepting Vague Requirements** | Don't want to probe | Always ask for examples, scenarios, metrics |
| **Missing Silent Stakeholders** | Focus on loud voices | Use power-interest matrix; proactively reach out |
| **Ignoring Non-Functional Requirements** | Focus on features | Dedicate specific sessions to NFRs |
| **One-and-Done Elicitation** | Time pressure | Plan for multiple sessions; expect iteration |
| **Leading Questions** | Unconscious bias | Frame questions neutrally; ask open-ended |
| **Not Validating Understanding** | Assumption of clarity | Summarize; ask for confirmation; use examples |
| **Forgetting to Document** | "I'll remember" | Document immediately; use templates |
| **Technology Over-Focus** | Comfortable with tech | Always start with business needs first |
| **Ignoring Existing Documentation** | Starting fresh | Always review before elicitation |

---

## 4.6 Check Your Understanding

### Knowledge Check Questions

**1. Why is "elicitation" a better term than "gathering" for requirements?**
```
[Your answer]
```

**2. What are the 3 phases of an interview process?**
```
[Your answer]
```

**3. What is the difference between a structured and unstructured interview?**
```
[Your answer]
```

**4. What are the key components of a successful workshop?**
```
[Your answer]
```

**5. How does Story Mapping differ from traditional requirements documentation?**
```
[Your answer]
```

**6. What is Event Storming and when would you use it?**
```
[Your answer]
```

**7. What are the advantages and disadvantages of surveys compared to interviews?**
```
[Your answer]
```

**8. What is document analysis and why is it important?**
```
[Your answer]
```

**9. What are the 4 brainstorming rules?**
```
[Your answer]
```

**10. What is the difference between observation and shadowing?**
```
[Your answer]
```

### Scenario Application

**Scenario:** You're leading a requirements workshop for a new e-commerce platform. The business sponsor keeps proposing solutions, technical team is worried about complexity, and one stakeholder is very dominant in the conversation.

**Question:** How would you handle this workshop to ensure productive outcomes?
```
[Your approach - what techniques would you use, how would you manage the dynamics, what would you do specifically?]
```

---

## 4.7 Summary & Reference

### Key Takeaways from Module 4

✅ Elicitation is active exploration, not passive collection
✅ Multiple techniques are needed for complete understanding
✅ Preparation is key to successful elicitation
✅ Active listening is the most important elicitation skill
✅ Different stakeholders need different elicitation approaches
✅ Workshops build consensus and alignment
✅ Story Mapping reveals the full user journey
✅ Event Storming surfaces complex process details
✅ Document analysis provides important context
✅ The Elicitation Plan guides all discovery activities

### Elicitation Technique Quick Reference

| Technique | Best For | Time Investment | Group Size |
|-----------|----------|-----------------|------------|
| Interviews | Deep individual insight | Medium | 1-on-1 |
| Workshops | Group alignment, consensus | High | 4-15 |
| Focus Groups | Collective perspectives | Medium | 6-10 |
| Brainstorming | Idea generation | Low-Medium | 4-15 |
| Observation | Understanding real workflow | Medium | 1-on-1 |
| Surveys | Broad input | Low | Unlimited |
| Document Analysis | Background research | Low-Medium | N/A |
| Story Mapping | User journey, prioritization | High | 4-10 |
| Event Storming | Process complexity | High | 6-15 |

### Module Deliverables Checklist

You should have completed these items for your portfolio:

- [ ] Interview Guide (for at least 2 stakeholder types)
- [ ] Workshop Plan (for at least 1 workshop)
- [ ] Focus Group Guide
- [ ] Observation Guide and Observation Notes
- [ ] Survey Design (for at least 1 target group)
- [ ] Document Analysis Summary
- [ ] Story Map (for a key process)
- [ ] Event Storming Model (for a key process)
- [ ] Complete Elicitation Plan for MediConnect
- [ ] Elicitation Activity Materials (agendas, guides, templates)

### Recommended Additional Reading

- BABOK® Guide v3, Chapter 4: Elicitation and Collaboration
- "User Story Mapping" by Jeff Patton
- "Event Storming" by Alberto Brandolini
- "Interviewing Users" by Steve Portigal
- "Gamestorming" by Gray, Brown, Macanufo
- "The Facilitator's Guide to Participatory Decision-Making" by Sam Kaner
- "Sprint" by Jake Knapp (Design Sprint methodology)
