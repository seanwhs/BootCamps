# Part 5 – Advanced Business Analysis & Modern Product Delivery

## Module 13: Agile Business Analysis

---

### Learning Objectives

By the end of this module, you will be able to:

- Articulate the Agile mindset and its impact on Business Analysis
- Apply BA practices within Scrum and Kanban frameworks
- Understand SAFe and scaled Agile environments
- Manage and refine product backlogs effectively
- Define and enforce Definition of Ready and Definition of Done
- Support sprint planning and execution as a BA
- Transition from traditional to Agile BA practices
- Produce a complete Agile BA toolkit

---

## 13.1 Core Concepts: Agile Business Analysis

### What is Agile Business Analysis?

**Agile Business Analysis** is the practice of applying business analysis principles and techniques within Agile development environments, emphasizing collaboration, flexibility, and iterative value delivery.

**The Agile BA Mindset:**

| Traditional BA | Agile BA |
|----------------|----------|
| Big upfront analysis | Just-in-time analysis |
| Complete documentation | Minimal sufficient documentation |
| Fixed requirements | Evolving requirements |
| Phase-gate approach | Continuous delivery |
| BA as documenter | BA as collaborator |
| Requirements sign-off | Continuous validation |
| Project completion | Ongoing product evolution |

**Analogy:** Traditional BA is like planning a wedding with a year of preparation and a single big day. Agile BA is like a weekly dinner party—you plan, prepare, serve, learn, and improve each time.

### The Agile Manifesto and BA

**Agile Values Applied to BA:**

| Agile Value | BA Implication |
|-------------|----------------|
| **Individuals and interactions** over processes and tools | BAs focus on stakeholder collaboration |
| **Working software** over comprehensive documentation | BAs deliver value, not documents |
| **Customer collaboration** over contract negotiation | BAs partner with stakeholders |
| **Responding to change** over following a plan | BAs embrace and adapt to change |

### The Agile BA Role

**Key Responsibilities:**

1. **Backlog Management:** Refine and prioritize backlog items
2. **Requirements Elicitation:** Continuous discovery
3. **User Stories:** Write, split, and refine stories
4. **Acceptance Criteria:** Define and validate
5. **Stakeholder Collaboration:** Facilitate communication
6. **Sprint Support:** Participate in planning, reviews, and retrospectives
7. **Testing Support:** Define acceptance tests
8. **Value Delivery:** Focus on delivering business value

### The Agile BA in Scrum

**Scrum Events and the BA:**

| Scrum Event | BA Participation |
|-------------|------------------|
| **Sprint Planning** | Help define sprint goal, refine stories, estimate |
| **Daily Scrum** | Provide updates, clarify requirements, remove impediments |
| **Sprint Review** | Present completed work, gather feedback |
| **Sprint Retrospective** | Reflect and improve BA practices |

---

## 13.2 Backlog Refinement

### What is Backlog Refinement?

**Backlog Refinement** (also called backlog grooming) is the ongoing process of reviewing, refining, and prioritizing backlog items to ensure they are ready for development.

**The Backlog Refinement Cycle:**

```
1. REVIEW
   ↓
   What's in the backlog?

2. PRIORITIZE
   ↓
   What's most important?

3. REFINE
   ↓
   Are stories ready for development?

4. SPLIT
   ↓
   Are stories the right size?

5. ESTIMATE
   ↓
   How much effort is needed?

6. VALIDATE
   ↓
   Do stakeholders agree?
```

### Backlog Refinement Activities

**Activity 1: User Story Refinement**

```
USER STORY REFINEMENT

Current Story:
"Patients should be able to book appointments online."

Refined Story:
As a patient,
I want to book an appointment online,
So that I can schedule care without calling during business hours.

Acceptance Criteria:
1. Patient can search for appointments by:
   - Date
   - Provider
   - Clinic
2. Available slots display with provider and location
3. Patient can select, confirm, and receive confirmation
4. Confirmation includes date/time, provider, location, instructions

Split Into Smaller Stories:
1. As a patient, I want to view available appointment slots
2. As a patient, I want to select an appointment time
3. As a patient, I want to confirm my appointment
4. As a patient, I want to receive confirmation
```

**Activity 2: Story Splitting**

| Technique | Example |
|-----------|---------|
| **By User Role** | Patient vs. Admin scheduling stories |
| **By Use Case** | Book, cancel, reschedule stories |
| **By Priority** | Must have vs. nice to have stories |
| **By Workflow** | Search, select, confirm, verify stories |
| **By Complexity** | Simple vs. complex scheduling stories |

**Activity 3: Estimation**

```
ESTIMATION TECHNIQUES

1. Story Points
   - Fibonacci sequence: 1, 2, 3, 5, 8, 13, 21
   - Effort + Complexity + Risk

2. T-Shirt Sizes
   - XS, S, M, L, XL, XXL

3. Planning Poker
   - Team estimates independently
   - Discuss differences
   - Reach consensus

4. Affinity Estimation
   - Group stories by size
   - Assign points to groups

Estimation Example:
Story: Book Appointment Online
- Effort: 3/5
- Complexity: 3/5
- Risk: 2/5
- Story Points: 5
```

### Backlog Refinement Meeting Template

```
BACKLOG REFINEMENT MEETING

Date: [Date]
Duration: 60 minutes
Participants: Product Owner, Development Team, BA

AGENDA:
1. Review backlog (5 min)
2. Prioritize backlog (10 min)
3. Refine top stories (20 min)
4. Estimate refined stories (15 min)
5. Define next steps (10 min)

OUTPUTS:
- Refined user stories
- Story point estimates
- Prioritized backlog
- Clear next actions

MEETING RULES:
- Keep stories ready for next 1-2 sprints
- Stories should be small enough for 1 sprint
- Acceptance criteria must be clear
- All participants contribute to estimation
```

### Your Turn: Backlog Refinement

Refine the following user story:

```
CURRENT STORY:
"The system should handle patient scheduling and improve efficiency."

REFINED STORY:
As a [who],
I want [what],
So that [why].

Acceptance Criteria:
1.
2.
3.

Split Into Smaller Stories (if needed):
1.
2.
3.
4.
```

---

## 13.3 Definition of Ready and Definition of Done

### What is Definition of Ready?

**Definition of Ready (DoR)** is the set of criteria that a user story must meet before it can be pulled into a sprint.

**Ready Checklist:**

```
DEFINITION OF READY (DoR)

A user story is ready when:
[ ] It is written in the "As a... I want... So that..." format
[ ] Acceptance criteria are defined and clear
[ ] It is sized appropriately (fits in one sprint)
[ ] Dependencies are identified and resolved
[ ] The team understands the story
[ ] It has been estimated (story points or size)
[ ] It is prioritized (priority is known)
[ ] Stakeholders are available for clarification
[ ] It is independent of other stories (where possible)
[ ] It is testable
```

### What is Definition of Done?

**Definition of Done (DoD)** is the set of criteria that a user story must meet before it is considered complete.

**Done Checklist:**

```
DEFINITION OF DONE (DoD)

A user story is done when:
[ ] Code is written
[ ] Code is reviewed (peer review)
[ ] Unit tests are written and pass
[ ] Integration tests pass
[ ] Acceptance criteria are met
[ ] User acceptance testing (UAT) is complete
[ ] Documentation is updated
[ ] Code is deployed to staging environment
[ ] No critical or high priority defects remain
[ ] Stakeholder accepts the story
[ ] Showback/demo is provided
[ ] Sign-off is obtained
```

### MediConnect Definition of Ready and Done

```
DEFINITION OF READY: MediConnect

A user story is ready when:
1. It is written in the "As a... I want... So that..." format
2. Acceptance criteria are defined, clear, and testable
3. It is sized appropriately (fits in one sprint, 3-8 story points)
4. Dependencies are identified and resolved
5. The team understands the story (can explain it back)
6. It has been estimated (story points assigned)
7. It is prioritized (product owner has set priority)
8. Stakeholders are available for clarification
9. It is independent of other stories or dependencies are manageable
10. It is testable (acceptance criteria are defined)

DEFINITION OF DONE: MediConnect

A user story is done when:
1. Code is written and meets coding standards
2. Code is reviewed (peer review completed)
3. Unit tests are written and pass
4. Integration tests pass
5. Acceptance criteria are met
6. User acceptance testing (UAT) is complete
7. Documentation is updated
8. Code is deployed to UAT environment
9. No critical or high priority defects remain
10. Stakeholder accepts the story
11. Demo is provided
12. Sign-off is obtained
```

---

## 13.4 Sprint Planning and Execution

### Sprint Planning

**Sprint Planning** is the event where the team decides what to deliver in the upcoming sprint.

**Sprint Planning Structure:**

```
SPRINT PLANNING

1. CAPACITY PLANNING
   - Team members available
   - Days off (holidays, sick, vacation)
   - Velocity (average points per sprint)
   - Capacity in story points

2. SPRINT GOAL
   - What is the purpose of this sprint?
   - What problem are we solving?

3. STORY SELECTION
   - Select stories from backlog
   - Prioritize by value and dependencies
   - Commit to delivery

4. TASK BREAKDOWN
   - Break stories into tasks
   - Assign tasks to team members
   - Estimate hours if needed
```

### MediConnect Sprint Planning Example

```
SPRINT PLANNING: MediConnect Sprint 5

CAPACITY:
- Team: 5 developers (full-time)
- Velocity: 25 points (average)
- Capacity: 25 points

SPRINT GOAL:
"Complete foundational patient scheduling capabilities"

SELECTED STORIES:
1. As a patient, I want to view available appointment slots (5 points)
2. As a patient, I want to book an appointment online (5 points)
3. As a patient, I want to receive confirmation (3 points)
4. As a patient, I want to cancel appointments online (2 points)
5. As a clinician, I want to view my schedule (5 points)
6. As an admin, I want to manage provider availability (5 points)

TOTAL: 25 points

TASK BREAKDOWN:
Story 1: View available appointment slots (5 points)
  - Design UI (2 hours) - Designer
  - Implement search (4 hours) - Developer 1
  - Implement display (4 hours) - Developer 2
  - Integration testing (2 hours) - QA
  - UAT (2 hours) - BA

SPRINT COMMITMENT:
- All 6 stories will be delivered
- No critical defects
- UAT sign-off obtained
```

### BA Role in Sprint Execution

**During Sprint:**

| Activity | BA Role |
|----------|---------|
| **Daily Standup** | Share progress, remove blockers, clarify requirements |
| **Development** | Answer questions, validate assumptions |
| **Testing** | Review test cases, assist with validation |
| **Demo Prep** | Help prepare demonstration |
| **Impediment Resolution** | Resolve issues impacting progress |
| **Requirements Clarification** | Clarify any ambiguity |

### Sprint Review

**Sprint Review** is where the team demonstrates completed work and gathers feedback.

**Sprint Review Structure:**

```
SPRINT REVIEW

1. DEMO
   - Show completed user stories
   - Demonstrate functionality
   - Walk through acceptance criteria

2. FEEDBACK
   - Stakeholders provide feedback
   - Questions and clarifications
   - Identify adjustments needed

3. DECISIONS
   - Accept stories as done
   - Request changes
   - Prioritize new items
```

### Sprint Retrospective

**Sprint Retrospective** is where the team reflects on what went well and what could be improved.

**Retrospective Structure:**

```
SPRINT RETROSPECTIVE

1. WHAT WENT WELL
   - Successes and wins
   - What to keep doing

2. WHAT COULD BE IMPROVED
   - Challenges and issues
   - What to change

3. ACTION ITEMS
   - Specific improvements
   - Who will do what
   - When will it be done

4. IMPROVEMENT TRACKING
   - Previous action items
   - Progress on improvements
   - Adjustments as needed
```

---

## 13.5 Agile BA in Scaled Environments

### Overview of SAFe

**SAFe (Scaled Agile Framework)** provides guidance for implementing Agile at enterprise scale.

**SAFe Core Values:**

1. **Alignment:** All levels aligned to strategy
2. **Built-in Quality:** Quality at every level
3. **Transparency:** Clear visibility
4. **Program Execution:** Deliver value consistently

### BA Role in SAFe

| SAFe Level | BA Role |
|------------|---------|
| **Portfolio** | Strategic analysis, investment decisions |
| **Program** | Requirements refinement, solution design |
| **Team** | Story refinement, UAT, testing support |

### Agile BA at Scale: Key Considerations

1. **Collaboration Across Teams**
   - Cross-team dependency management
   - Shared backlog refinement
   - Integration support

2. **Standardization**
   - Common definition of ready/done
   - Consistent story format
   - Shared tools and practices

3. **Coordination**
   - Program-level planning
   - Release management
   - Synchronization

4. **Governance**
   - Traceability
   - Compliance
   - Reporting

---

## 13.6 Transitioning from Traditional to Agile BA

### The Transition Journey

**Where to Start:**

| Phase | Focus | Activities |
|-------|-------|------------|
| **Phase 1: Mindset** | Embrace Agile values | Collaboration over documentation |
| **Phase 2: Practices** | Adopt Agile practices | Iterative, just-in-time analysis |
| **Phase 3: Tools** | Use Agile tools | Jira, backlog, story mapping |
| **Phase 4: Scaling** | Extend to enterprise | SAFe, scaled practices |

### Common Challenges and Solutions

| Challenge | Solution |
|-----------|----------|
| **"We need documents"** | Just-in-time documentation |
| **"Requirements change too much"** | Embrace change as value |
| **"We need sign-off"** | Continuous validation |
| **"We don't know what's next"** | Backlog refinement |
| **"We're not Agile"** | Start with practices, build mindset |

### Agile BA Assessment

**Assess Your Agile BA Maturity:**

| Level | Description |
|-------|-------------|
| **Level 1** | Traditional BA, documents-first |
| **Level 2** | Experimenting with Agile practices |
| **Level 3** | Consistent Agile BA practices |
| **Level 4** | Advanced Agile BA, continuous improvement |
| **Level 5** | Agile BA leadership, scaling practices |

---

## 13.7 Hands-On: Agile BA Artifacts

### Your Task: Create the Agile BA Package

**Deliverable 1: Agile BA Mindset Assessment**

Assess your Agile BA maturity and identify areas for growth.

**Deliverable 2: Backlog Refinement Process**

Document your backlog refinement process.

**Deliverable 3: Definition of Ready and Done**

Create DoR and DoD for your project.

**Deliverable 4: Sprint Planning Example**

Create a sprint planning session for a sample sprint.

**Deliverable 5: User Story Refinement**

Refine 5 user stories with acceptance criteria.

**Deliverable 6: Agile BA Transition Plan**

Create a plan to transition from traditional to Agile BA.

**Deliverable 7: Agile BA Summary**

Compile all artifacts into a complete Agile BA package.

---

## 13.8 Check Your Understanding

### Knowledge Check Questions

**1. What is the difference between traditional and Agile BA?**
```
[Your answer]
```

**2. What is backlog refinement and why is it important?**
```
[Your answer]
```

**3. What is the difference between Definition of Ready and Definition of Done?**
```
[Your answer]
```

**4. What is the BA's role in sprint planning?**
```
[Your answer]
```

**5. What is the BA's role in sprint execution?**
```
[Your answer]
```

**6. What is the difference between a user story and a requirement?**
```
[Your answer]
```

**7. How do you handle changing requirements in Agile?**
```
[Your answer]
```

**8. What is the BA's role in a scaled Agile environment?**
```
[Your answer]
```

**9. How do you transition from traditional to Agile BA?**
```
[Your answer]
```

**10. What are the key skills for an Agile BA?**
```
[Your answer]
```

---

## 13.9 Summary & Reference

### Key Takeaways from Module 13

✅ Agile BA is about collaboration, not documentation
✅ Backlog refinement is ongoing
✅ Definition of Ready and Done enable quality
✅ Sprint planning sets direction
✅ Sprint review gathers feedback
✅ Sprint retrospective drives improvement
✅ Scaled Agile requires coordination
✅ Transition requires mindset and practice

### Agile BA Quick Reference

| Artifact | Purpose | Audience |
|----------|---------|----------|
| User Stories | Requirements | Dev, QA, Stakeholders |
| Acceptance Criteria | What Done looks like | Dev, QA |
| Product Backlog | All work to be done | PO, Team |
| Sprint Backlog | Work for current sprint | Team |
| DoR | Ready for sprint | PO, Team |
| DoD | Complete | Team, Stakeholders |

### Module Deliverables Checklist

You should have completed these items for your portfolio:

- [ ] Agile BA Mindset Assessment
- [ ] Backlog Refinement Process
- [ ] Definition of Ready and Definition of Done
- [ ] Sprint Planning Example
- [ ] User Story Refinement (5 stories)
- [ ] Agile BA Transition Plan
- [ ] Agile BA Summary Report

### Recommended Additional Reading

- BABOK® Guide v3, Agile Extension
- "Agile Business Analysis" by Agile Extension
- "User Stories Applied" by Mike Cohn
- "Scrum" by Jeff Sutherland
- "Agile Product Management" by Roman Pichler
- "The Agile Samurai" by Jonathan Rasmusson

The next module will launch immediately in the following response.
