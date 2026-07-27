## Part 8: Working with Engineering

### Core Concept: From PRD to Working Software

You've written a comprehensive PRD. You have user stories, acceptance criteria, and success metrics. Now comes the critical phase: **turning that document into a working product.**

Here's a truth that separates great PMs from good ones:

> *"A PRD is not a contract. It's a conversation starter."*

Your job as a PM isn't to throw requirements over the wall. It's to collaborate with engineering to build the best possible product—which means being flexible, pragmatic, and deeply engaged throughout the development process.

### The Engineering Partnership

Think of the PM-Engineering relationship as a partnership:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE PM-ENGINEERING PARTNERSHIP                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        SHARED GOALS                              │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Ship a great product that users love                        │   │
│  │  • Hit our metrics (retention, activation, etc.)              │   │
│  │  • Build sustainably (minimize technical debt)                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────────┐    ┌──────────────────────────┐         │
│  │         PM               │    │      ENGINEERING          │         │
│  │  ──────────────────────── │    │  ──────────────────────── │         │
│  │  • Defines the "what"    │    │  • Defines the "how"      │         │
│  │  • Understands the user  │    │  • Understands the        │         │
│  │    and the business      │    │    technology             │         │
│  │  • Prioritizes features  │    │  • Suggests alternatives  │         │
│  │  • Writes clear          │    │  • Estimates effort       │         │
│  │    requirements          │    │  • Spots edge cases       │         │
│  │  • Validates that        │    │  • Implements solutions   │         │
│  │    requirements are met  │    │  • Maintains code         │         │
│  └──────────────────────────┘    └──────────────────────────┘         │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     COLLABORATION POINTS                         │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Sprint planning            • Daily standups                 │   │
│  │  • Refinement sessions        • Technical design reviews       │   │
│  │  • Demos                     • Retros                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### The Development Lifecycle

Here's how the process typically flows in an agile environment:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE DEVELOPMENT LIFECYCLE                           │
│                                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   PLAN       │    │   BUILD      │    │   REVIEW     │    │   SHIP       │  │
│  │              │───▶│              │───▶│              │───▶│              │  │
│  │  • Backlog   │    │  • Code      │    │  • QA        │    │  • Deploy    │  │
│  │  • Refinement│    │  • Tests     │    │  • Demo      │    │  • Monitor   │  │
│  │  • Sprint    │    │  • Reviews   │    │  • UAT       │    │  • Validate  │  │
│  └──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                     ITERATE                                             │   │
│  │  ───────────────────────────────────────────────────────────────────── │   │
│  │  • Gather data                                                         │   │
│  │  • Learn from users                                                    │   │
│  │  • Refine the backlog                                                  │   │
│  │  • Start again                                                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## The Ledgerly Scenario: Working with the Engineering Team

### The Team Setup

You're the PM for Ledgerly. The engineering team consists of:

- **4 Engineers:** 2 backend, 2 frontend
- **1 Engineering Manager:** Coordinates the team, handles technical planning
- **1 Designer:** Works closely with you and the engineers

### Your Role in the Process

As the PM, you're responsible for:

1. **Being the voice of the user:** Ensure the team understands *why* we're building what we're building
2. **Defining the "what":** Clarify requirements when questions arise
3. **Unblocking the team:** Remove obstacles so engineers can focus
4. **Managing scope:** Help the team make trade-offs when things get tight
5. **Validating the product:** Ensure what we build meets the requirements

### What You DON'T Do

- **Tell engineers how to code:** That's their domain
- **Assign tasks:** The engineering manager handles that
- **Micromanage:** Trust your team to do their job

---

## Framework Deep Dive: Agile Development for PMs

### What Is Agile?

Agile is a set of principles for software development that emphasizes:

- **Individuals and interactions** over processes and tools
- **Working software** over comprehensive documentation
- **Customer collaboration** over contract negotiation
- **Responding to change** over following a plan

It's not a specific methodology. It's a mindset. Scrum and Kanban are frameworks that implement agile principles.

### Scrum Basics

Scrum is the most common agile framework. Here's what you need to know as a PM:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     SCRUM AT A GLANCE                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  BACKLOG                                                       │   │
│  │  • All the things we might build                               │   │
│  │  • Prioritized by the PM                                       │   │
│  │  • Refined continuously                                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SPRINT PLANNING (Start of Sprint)                              │   │
│  │  • Team commits to specific backlog items                      │   │
│  │  • PM explains priorities and context                          │   │
│  │  • Team estimates effort                                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SPRINT (1-2 weeks)                                            │   │
│  │  • Daily standups (PM attends, listens, unblocks)             │   │
│  │  • Development happens                                          │   │
│  │  • PM is available for questions                               │   │
│  │  • Mid-sprint check-in                                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SPRINT REVIEW (End of Sprint)                                  │   │
│  │  • Demo what was built                                          │   │
│  │  • PM validates against requirements                           │   │
│  │  • Stakeholders provide feedback                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SPRINT RETROSPECTIVE                                           │   │
│  │  • What went well?                                             │   │
│  │  • What could be improved?                                      │   │
│  │  • What will we change next sprint?                            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Kanban Basics

Kanban is an alternative to Scrum. It emphasizes continuous flow rather than fixed sprints.

**Key Differences:**
- **Scrum:** Fixed-length sprints; planned scope
- **Kanban:** Continuous flow; pull-based system

**Why Choose One:**
- **Scrum:** Good for complex projects with uncertain scope (new features)
- **Kanban:** Good for maintenance or operations (bug fixes, small features)

---

## Hands-On Exercise: Working with Engineering

### Step 1: Sprint Planning

You're at sprint planning for the first sprint of the Goal Setting feature. Here's the team's capacity:

- **Sprint Duration:** 2 weeks
- **Team Velocity:** 40 story points per sprint
- **Available Engineers:** 4

**Your Backlog (with estimates from engineering):**

| Story | Points | Priority |
|-------|--------|----------|
| Create Savings Goal | 8 | P0 |
| Create Spending Goal | 5 | P0 |
| Create Debt Goal | 5 | P1 |
| View Goal Progress | 8 | P0 |
| Goal Detail View | 5 | P1 |
| Edit Goals | 3 | P1 |
| Delete Goals | 2 | P2 |
| Goal Suggestions | 8 | P2 |
| Notifications | 8 | P1 |
| Dashboard Widget | 5 | P0 |

**Your Task:** Select stories for the sprint (total ≤ 40 points).

### Step 2: Make the Decision

Create a document called `sprint-planning.md` in your `03-execution/` folder:

```markdown
# Ledgerly: Sprint Planning - Goal Setting

## Sprint Goal
To deliver the core Goal Setting functionality: users can create a goal and see progress on their dashboard.

## Sprint Details
- **Sprint Duration:** 2 weeks
- **Team Capacity:** 40 story points
- **Focus:** Create goals, view progress, and dashboard integration

## Selected Stories

| Story | Points | Priority | Why |
|-------|--------|----------|-----|
| Create Savings Goal | 8 | P0 | Core functionality; user can't set a goal without this |
| View Goal Progress | 8 | P0 | Users need to see progress; critical for motivation |
| Dashboard Widget | 5 | P0 | Goals must be visible on dashboard |
| Create Spending Goal | 5 | P0 | Second goal type; expands feature coverage |
| Edit Goals | 3 | P1 | Users need to modify goals; likely to be needed early |
| Create Debt Goal | 5 | P1 | Third goal type; important but can be next sprint |

**Total:** 34 points (within 40-point capacity)

## Stories Carried Forward to Next Sprint

| Story | Points | Priority | Why |
|-------|--------|----------|-----|
| Goal Detail View | 5 | P1 | Can ship in next sprint |
| Notifications | 8 | P1 | Not blocking core functionality |
| Delete Goals | 2 | P2 | Can ship later |
| Goal Suggestions | 8 | P2 | V2 feature |

## Sprint Trade-offs
**What we're doing:** Core goal creation, progress tracking, and dashboard integration.
**What we're deferring:** Goal detail view, notifications, and advanced features.

**Why:** We want to get the core functionality in users' hands quickly. The deferred features are "nice to have" but not blocking the core value proposition.
```

### Step 3: Daily Standup Participation

During the sprint, you attend daily standups. Here's how you participate:

```markdown
# Ledgerly: PM Participation in Daily Standup

## PM's Role in Standup

As a PM, I don't report on tasks. Instead, I:
1. **Listen:** Understand progress and blockers
2. **Unblock:** If engineers are blocked on product decisions, resolve them
3. **Clarify:** If requirements are unclear, provide clarification
4. **Coordinate:** Connect engineers with stakeholders or resources

## How I Prepare for Standup

**Before Standup:**
- Review yesterday's progress
- Check for any blockers or questions
- Review the sprint backlog

**During Standup:**
- Listen to each engineer's update
- Note blockers that require product decisions
- Provide clarifications if needed
- Confirm any changes to priorities

**After Standup:**
- Follow up on blockers
- Communicate any changes to stakeholders
- Document decisions made in standup
```

### Step 4: Managing Scope Changes

During the sprint, you'll inevitably face scope changes. Here's how to handle them:

```markdown
# Ledgerly: Managing Scope Changes

## Scenario: The Team Discovers a Technical Issue

**The Situation:** Engineering discovers that connecting goal progress to transactions is more complex than expected. They estimate an additional 3 story points (extra 2 days of work).

**Your Decision Options:**
1. **Cut scope:** Remove lower-priority stories from the sprint
2. **Add time:** Extend the sprint (not ideal)
3. **Negotiate:** Find a simplified solution with engineering

**Your Decision:** Negotiate a simplified solution.

**The Compromise:**
- Instead of real-time progress tracking, update progress daily in a batch job
- This reduces complexity while still delivering value
- Users see "updated today" rather than "updated in real time"
- Real-time tracking becomes a future enhancement

**How You Communicate It:**
- To engineering: "Great idea. Let's batch update daily."
- To stakeholders: "We're adjusting the timeline slightly to ensure quality."
- In the sprint: Update the backlog and adjust estimates.
```

### Step 5: Sprint Review

At the end of the sprint, you review what was built:

```markdown
# Ledgerly: Sprint Review - Goal Setting Sprint 1

## What We Built

✅ **Create Savings Goal:** Users can set a savings goal with target amount and date
✅ **Create Spending Goal:** Users can set a spending goal with category and limit
✅ **View Goal Progress:** Goals appear on dashboard with progress bars
✅ **Dashboard Widget:** Goals are displayed prominently on dashboard
✅ **Edit Goals:** Users can modify goal parameters after creation

## What We Didn't Build

❌ **Create Debt Goal:** Deferred to next sprint
❌ **Goal Detail View:** Deferred to next sprint
❌ **Notifications:** Deferred to next sprint
❌ **Delete Goals:** Deferred to next sprint

## Demo Highlights

### Demo 1: Create a Savings Goal
[Screenshot of goal creation flow]
- User selects "Savings Goal"
- User enters $1,000 target
- User selects Dec 31, 2024 target date
- Goal appears on dashboard

### Demo 2: Dashboard View
[Screenshot of dashboard with goals]
- Three goals displayed with progress bars
- "On Track" / "Behind" indicators
- Progress updates daily via batch job

### Demo 3: Edit Goal
[Screenshot of edit flow]
- User clicks "Edit" on a goal
- User changes target from $1,000 to $1,500
- Goal updates immediately

## Feedback from Stakeholders

**Positive:**
- "The progress bars look great."
- "Goal creation is simple and clear."

**Requests:**
- "Can we add a motivational message?"
- "When will we have notifications?"

**Our Response:**
- Motivational messages: Added to backlog
- Notifications: Planned for next sprint

## Metrics Check

- **Goal adoption:** 32% of new users set a goal (approaching 50% target)
- **Retention:** Goal-setting users at 28% retention (approaching 40% target)
- **Satisfaction:** 4.2/5 rating from goal-setting users
- **We're on track!**

## Next Sprint Focus

1. Goal Detail View
2. Notifications
3. Delete Goals
4. Additional goal types (Debt)
```

---

## Expert Pro Tips: Working with Engineering

### Tip 1: Build Relationships, Not Just Features

Your relationship with engineers is more important than any single feature. Build trust by:

- **Being reliable:** Show up prepared and on time
- **Being transparent:** Share both good and bad news
- **Being respectful:** Acknowledge their expertise
- **Being available:** Make yourself available for questions

### Tip 2: Learn Enough Technical Context

You don't need to code, but you should understand:

- **How the system works:** Basic architecture and data flow
- **What's hard and what's easy:** So you can make better trade-offs
- **Technical constraints:** So you don't propose impossible features
- **The team's capacity:** So you can set realistic expectations

### Tip 3: Embrace the "Minimum Viable Product" Mentality

You don't have to build everything at once. Start with the minimum that delivers value, then iterate.

**For Goal Setting:**
- **MVP:** Set a goal, see progress on dashboard
- **V2:** Detailed view, notifications, multiple goal types
- **V3:** Recommendations, social features, advanced analytics

### Tip 4: Say "Yes, And" Not "No, But"

When engineering says something is hard, don't just say "no." Say "yes, and" to find a compromise:

**The "No, But" Approach:**
> "That feature is too hard. We can't build it."

**The "Yes, And" Approach:**
> "That feature is hard. What if we build a simplified version and iterate over time?"

### Tip 5: Over-Communicate, Especially When Things Go Wrong

If something is going to be delayed, tell stakeholders immediately. Don't wait until the end of the sprint.

**Good Communication:**
> "Engineering discovered a technical complexity with progress tracking. We're working on a solution. We might miss our Tuesday deadline by 2-3 days."

**Bad Communication:**
> "Sorry, we're behind. We'll deliver when we can."

### Tip 6: Celebrate Success (and Learn from Failure)

When something goes well, celebrate with the team. When something goes wrong, do a retrospective and learn.

**Celebration Ideas:**
- "Ship it!" moments (team celebration when feature launches)
- Demo days (show what you've built)
- Team lunch or event

**Learning from Failure:**
- Blameless post-mortems (focus on process, not people)
- Action items (what will we change next time?)
- Documentation (capture learnings)

### Tip 7: Remove Friction

As a PM, you're the "friction remover." When engineers are blocked, unblock them.

**Common Blocks:**
- Unclear requirements (clarify them)
- Dependencies on other teams (coordinate)
- Stakeholder indecision (drive decisions)
- Technical questions (find answers)

---

## The Bigger Picture: Where Part 8 Fits in Your Portfolio

This is the final part of Phase 3: Execution & Delivery.

### What You've Accomplished:

✅ **You understand the development process:** From sprint planning to shipping  
✅ **You've practiced working with engineering:** Sprint planning, daily standups, scope management  
✅ **You've done a sprint review:** You know how to validate what was built  

### What's Coming Next:

In **Part 9: Metrics & Analytics**, we shift from building to measuring. You'll learn how to define and track product metrics, analyze user behavior, and make data-driven decisions.

### How This Connects:

Your sprint review in Part 8 included metrics on goal adoption and retention. In Part 9, you'll dive deeper into analytics—setting up dashboards, tracking funnels, and using data to drive growth.

---

## Verification: Part 8 Completion Checklist

Before moving to Part 9, ensure you've completed the following:

- [ ] Created sprint planning document
- [ ] Documented your PM role in daily standups
- [ ] Practiced managing scope changes
- [ ] Completed a sprint review document
- [ ] Created all documents in your `03-execution/` folder
- [ ] Committed your work to your portfolio repository

---

## Part 8 Summary: Key Takeaways

| Concept | Key Insight |
|---------|-------------|
| **PM-Engineering Partnership** | Collaboration, not command |
| **Agile Development** | Plan, Build, Review, Ship, Iterate |
| **Scrum** | Fixed sprints, planned scope |
| **Sprint Planning** | Select stories for the sprint |
| **Daily Standup** | PM listens, unblocks, clarifies |
| **Scope Management** | Make trade-offs pragmatically |
| **Sprint Review** | Demo and validate what was built |
| **Metrics** | Track adoption, retention, satisfaction |

---

## Self-Check: Quick Knowledge Test

**1. What's the PM's role in sprint planning?**

<details>
<summary>Click to reveal answer</summary>

The PM explains priorities and context, while the engineering team selects stories and estimates effort. The PM doesn't assign tasks; the engineering manager handles that.
</details>

**2. What should a PM do in daily standup?**

<details>
<summary>Click to reveal answer</summary>

Listen to progress, unblock engineers on product decisions, clarify requirements, and coordinate with stakeholders. The PM doesn't report on tasks.
</details>

**3. Why is it important to say "yes, and" instead of "no, but"?**

<details>
<summary>Click to reveal answer</summary>

"Yes, and" finds compromises and solutions. "No, but" shuts down conversation. A collaborative approach builds trust and delivers better products.
</details>

**4. What's the difference between Scrum and Kanban?**

<details>
<summary>Click to reveal answer</summary>

Scrum uses fixed-length sprints with planned scope. Kanban uses continuous flow with pull-based work. Scrum is good for complex features; Kanban is good for maintenance and support.
</details>

---

## Phase 3 Complete: What You've Built

Congratulations! You've completed Phase 3: Execution & Delivery. Here's what you now have in your portfolio:

```
03-execution/
├── prd-goal-setting.md            # Complete Product Requirements Document
├── user-stories-goal-setting.md   # User stories with acceptance criteria
├── user-flow-goal-setting.md      # User flows for key journeys
├── sprint-planning.md             # Sprint planning document
└── sprint-review.md               # Sprint review and metrics

```

You've taken an idea from concept to reality. You've written requirements, planned sprints, collaborated with engineering, and validated what was built. This is the core of product execution.

---

## Looking Ahead: Prepare for Part 9

Before the next part, take a moment to consider:

- What metrics matter most for Ledgerly?
- How do you measure user engagement?
- What would a metrics dashboard look like?

In Part 9, we'll answer these questions as we dive into product analytics—the data that tells you if your product is succeeding.
