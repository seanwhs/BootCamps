# Primer 5: The Execution Primer - Ship Products Like a Pro

## Overview

This primer is designed for readers who want to master the **execution phase** of product management. This is where you turn strategy into reality—writing requirements, working with engineering, and shipping products that users love.

**Purpose:** To give you a complete, actionable framework for flawless product execution, in 15 minutes.

---

## What This Primer Covers

1. **What Execution Is** (And Why It Matters)
2. **The 4 Pillars of Execution** (Plan, Build, Review, Ship)
3. **The PRD Masterclass** (How to Write Requirements Engineers Love)
4. **The Agile Workshop** (Sprints, Standups, and Shipping)
5. **The Engineering Partnership** (Working with Developers)
6. **The 5 Execution Pitfalls** (And How to Avoid Them)
7. **Your Execution Mantra** (The One Rule That Guides Everything)

---

## 1. What Execution Is (And Why It Matters)

### The 30-Second Definition

> **Execution is the process of translating product strategy into a working product by writing clear requirements, collaborating with engineering and design, managing scope, and shipping quality software on schedule.**

### The Execution Gap

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE EXECUTION GAP                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                                                                 │   │
│  │  STRATEGY  ───────────────▶  EXECUTION  ───────────────▶  SHIP │   │
│  │  (Vision, 20%)             (Process, 60%)         (Product, 20%)│   │
│  │                                                                 │   │
│  │  The Gap: Most teams have good strategy but poor execution.    │   │
│  │  Great teams have both.                                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  EXECUTION IS WHERE MOST TEAMS FAIL:                           │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • 70% of products fail due to poor execution, not strategy   │   │
│  │  • 50% of features are never used as intended                 │   │
│  │  • 40% of projects ship late or over budget                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why Execution Matters

1. **Strategy is worthless without execution**—A great strategy poorly executed is worse than no strategy at all
2. **Execution is what users actually experience**—They don't see your strategy; they see your product
3. **Execution builds trust**—Reliably shipping quality products earns stakeholder confidence
4. **Execution is repeatable**—Great execution creates a system for shipping great products again and again

---

## 2. The 4 Pillars of Execution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE 4 PILLARS OF EXECUTION                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  PILLAR 1: PLAN                                                 │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Write the PRD                                              │   │
│  │  • Define user stories and acceptance criteria                │   │
│  │  • Plan the sprint                                             │   │
│  │  • Estimate effort                                             │   │
│  │                                                                 │   │
│  │  Key Question: "What exactly are we building?"                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  PILLAR 2: BUILD                                               │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Work with engineering during development                   │   │
│  │  • Attend daily standups                                       │   │
│  │  • Unblock the team                                            │   │
│  │  • Manage scope changes                                        │   │
│  │                                                                 │   │
│  │  Key Question: "How do we build it right?"                    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  PILLAR 3: REVIEW                                              │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Conduct QA testing                                          │   │
│  │  • Run user acceptance testing (UAT)                          │   │
│  │  • Demo to stakeholders                                        │   │
│  │  • Get feedback                                               │   │
│  │                                                                 │   │
│  │  Key Question: "Did we build what we intended?"               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  PILLAR 4: SHIP                                                │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Deploy to production                                        │   │
│  │  • Monitor for issues                                          │   │
│  │  • Validate metrics                                            │   │
│  │  • Celebrate success                                           │   │
│  │                                                                 │   │
│  │  Key Question: "Did it work?"                                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. The PRD Masterclass

### What Is a PRD?

**Product Requirements Document** = The blueprint for what you're building.

### The PRD Structure

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     PRD STRUCTURE                                       │
│                                                                         │
│  1. Executive Summary                                                  │
│     ───────────────────                                                │
│     What are we building and why? (1 paragraph)                       │
│                                                                         │
│  2. Problem Statement                                                  │
│     ───────────────────                                                │
│     What problem are we solving?                                      │
│                                                                         │
│  3. User Stories                                                       │
│     ────────────────                                                   │
│     As a [user], I want [goal], So that [reason]                     │
│                                                                         │
│  4. Success Metrics                                                    │
│     ─────────────────                                                  │
│     How will we know if it worked?                                    │
│                                                                         │
│  5. Detailed Requirements                                              │
│     ────────────────────                                               │
│     Functional, non-functional, and technical requirements           │
│                                                                         │
│  6. Dependencies & Assumptions                                         │
│     ─────────────────────────────                                      │
│     What needs to be true for this to work?                          │
│                                                                         │
│  7. Out of Scope                                                       │
│     ─────────────                                                      │
│     What are we NOT building?                                        │
└─────────────────────────────────────────────────────────────────────────┘
```

### User Stories: The Heart of the PRD

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     USER STORY TEMPLATE                                 │
│                                                                         │
│  As a [type of user],                                                   │
│  I want [some goal],                                                    │
│  So that [some reason].                                                │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                         │
│  Example:                                                              │
│  As a user who wants to save money,                                   │
│  I want to set a savings goal with a target amount and deadline,      │
│  So that I have a clear target to work toward.                       │
│                                                                         │
│  ACCEPTANCE CRITERIA:                                                 │
│  ────────────────────                                                 │
│  • [ ] User can access "Set a Goal" from dashboard                   │
│  • [ ] User can select "Savings Goal" from goal types                │
│  • [ ] User can enter target amount (minimum $1)                    │
│  • [ ] User can enter target date (must be future date)             │
│  • [ ] User can save goal after entering required fields            │
│  • [ ] Goal appears on dashboard with progress bar at 0%           │
│  • [ ] User receives confirmation message on successful save        │
│                                                                         │
│  EDGE CASES:                                                          │
│  ────────────                                                         │
│  • Invalid amount (0 or negative): show error message               │
│  • Past target date: show error message                             │
│  • Missing required fields: show error message                      │
│  • User cancels goal creation: no goal is saved                    │
└─────────────────────────────────────────────────────────────────────────┘
```

### PRD Best Practices

| Do | Don't |
|----|-------|
| Write for your audience (engineering, design, QA) | Write for yourself |
| Be specific and testable | Be vague and ambiguous |
| Include edge cases and error states | Only include the happy path |
| Define success metrics | Ship without metrics |
| State what's out of scope | Let scope creep happen |
| Get buy-in before building | Surprise stakeholders |

---

## 4. The Agile Workshop

### Scrum: The Most Common Agile Framework

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

### The PM's Role in Each Ceremony

| Ceremony | Your Role |
|----------|-----------|
| **Backlog Refinement** | Prioritize, clarify, add context |
| **Sprint Planning** | Explain priorities, answer questions |
| **Daily Standup** | Listen, unblock, clarify |
| **Sprint Review** | Validate, demo, gather feedback |
| **Sprint Retrospective** | Participate, learn, improve |

### Managing Scope: The PM's Superpower

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     MANAGING SCOPE                                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  TRADE-OFF TRIANGLE                                             │   │
│  │                                                                 │   │
│  │                         SCOPE                                  │   │
│  │                         ▲                                      │   │
│  │                        / \                                     │   │
│  │                       /   \                                    │   │
│  │                      /     \                                   │   │
│  │                     /       \                                  │   │
│  │                    /  Trade- \                                 │   │
│  │                   /   off    \                                 │   │
│  │                  /  Triangle  \                                │   │
│  │                 /              \                               │   │
│  │                /                \                              │   │
│  │               /                  \                             │   │
│  │          TIME ◄───────────────────► QUALITY                   │   │
│  │                                                                 │   │
│  │  You can't have all three. Choose two.                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SCOPE MANAGEMENT STRATEGIES:                                  │   │
│  │                                                                 │   │
│  │  1. Cut scope (remove lower-priority features)                │   │
│  │  2. Add time (extend timeline)                                │   │
│  │  3. Reduce quality (not recommended)                         │   │
│  │  4. Negotiate compromise (find a simpler solution)            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 5. The Engineering Partnership

### Building a Great Relationship with Engineers

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE ENGINEERING PARTNERSHIP                        │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  THE PM-ENGINEERING RELATIONSHIP:                               │   │
│  │                                                                 │   │
│  │  PM: "What" (What we're building and why)                     │   │
│  │  Engineering: "How" (How we'll build it)                      │   │
│  │                                                                 │   │
│  │  Both: "Why" (Why it matters to users)                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  5 WAYS TO BUILD TRUST WITH ENGINEERING:                       │   │
│  │                                                                 │   │
│  │  1. BE PREPARED                                                │   │
│  │     Show up with clear requirements and context               │   │
│  │                                                                 │   │
│  │  2. BE AVAILABLE                                              │   │
│  │     Answer questions quickly to unblock the team              │   │
│  │                                                                 │   │
│  │  3. BE HONEST                                                 │   │
│  │     Admit when you don't know something                       │   │
│  │                                                                 │   │
│  │  4. BE PROTECTIVE                                              │   │
│  │     Shield the team from unnecessary distractions             │   │
│  │                                                                 │   │
│  │  5. BE GRATEFUL                                                 │   │
│  │     Acknowledge their work and celebrate wins                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### What Engineers Wish You Knew

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     WHAT ENGINEERS WISH PMS KNEW                       │
│                                                                         │
│  1. "WE WANT CLARITY, NOT PERFECTION"                                 │
│     ───────────────────────────────────────────────────────────────   │
│     Don't wait for the perfect PRD. Give us enough to start. We     │
│     can iterate.                                                     │
│                                                                         │
│  2. "WE RESPECT YOUR DOMAIN"                                          │
│     ───────────────────────────────────────────────────────────────   │
│     We trust you to define the 'what.' Trust us to define the 'how.' │
│                                                                         │
│  3. "WE HATE SURPRISES"                                              │
│     ───────────────────────────────────────────────────────────────   │
│     If you're going to change the scope, tell us ASAP.               │
│                                                                         │
│  4. "WE WANT TO BE INVOLVED EARLY"                                   │
│     ───────────────────────────────────────────────────────────────   │
│     Include us in discovery and strategy. We can help spot issues   │
│     early.                                                           │
│                                                                         │
│  5. "WE WANT TO KNOW THE WHY"                                        │
│     ───────────────────────────────────────────────────────────────   │
│     Tell us why this matters to users. It motivates us.            │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 6. The 5 Execution Pitfalls

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     5 EXECUTION PITFALLS                                │
│                                                                         │
│  PITFALL 1: WRITING THE PERFECT PRD                                   │
│  ──────────────────────────────────                                    │
│  ❌ Mistake: Spending weeks perfecting the PRD before sharing it      │
│  ✅ Fix: Share a "good enough" PRD early and iterate                  │
│  The goal is to start building, not to perfect a document.           │
│                                                                         │
│  PITFALL 2: THROWING REQUIREMENTS OVER THE WALL                      │
│  ──────────────────────────────────────────                            │
│  ❌ Mistake: Writing a PRD and walking away                           │
│  ✅ Fix: Engage with engineering throughout development               │
│  A PRD is a conversation starter, not a contract.                   │
│                                                                         │
│  PITFALL 3: SAYING YES TO EVERYTHING                                 │
│  ─────────────────────────────────                                    │
│  ❌ Mistake: Accepting every feature request                          │
│  ✅ Fix: Have a clear "no" and use frameworks to decide              │
│  Saying yes to everything means shipping nothing on time.           │
│                                                                         │
│  PITFALL 4: FORGETTING EDGE CASES                                    │
│  ─────────────────────────────                                        │
│  ❌ Mistake: Only considering the happy path                         │
│  ✅ Fix: Think about error states, edge cases, and failure modes     │
│  Users will find every edge case you didn't think of.              │
│                                                                         │
│  PITFALL 5: SHIPPING AND MOVING ON                                   │
│  ─────────────────────────────                                        │
│  ❌ Mistake: Launching and immediately moving to the next feature    │
│  ✅ Fix: Monitor metrics, validate, and iterate                      │
│  Shipping is the start, not the end, of the product's life.        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Your Execution Mantra

### The One Rule That Guides Everything

When you're writing a PRD, when you're planning a sprint, when you're launching a feature—come back to this:

> *"Build the simplest thing that could possibly work, ship it, and learn from what happens next."*

### Why This Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE EXECUTION MANTRA                                │
│                                                                         │
│  "BUILD THE SIMPLEST THING THAT COULD POSSIBLY WORK..."               │
│  ───────────────────────────────────────────────────────────────       │
│  • Prevents over-engineering                                          │
│  • Focuses on the MVP                                                │
│  • Reduces scope creep                                                │
│  • Gets you to market faster                                         │
│                                                                         │
│  "...SHIP IT..."                                                      │
│  ───────────────────────────────────────────────────────────────       │
│  • Perfection is the enemy of done                                   │
│  • You learn more from shipping than planning                       │
│  • Users are the best testers                                        │
│                                                                         │
│  "...AND LEARN FROM WHAT HAPPENS NEXT."                             │
│  ───────────────────────────────────────────────────────────────       │
│  • The product is never finished                                     │
│  • Data and feedback guide iteration                                │
│  • Every launch is a learning opportunity                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### Applying the Mantra

| Decision | Mantra Says... |
|----------|----------------|
| "Should we add more features to the MVP?" | No. Build the simplest thing that works. |
| "Should we wait until the PRD is perfect?" | No. Ship it and learn. |
| "Should we stop measuring after launch?" | No. Learn from what happens next. |
| "Should we build this complex feature now?" | No. Start simple and iterate. |

---

## Primer Summary: What You Now Know

### Your 15-Minute Execution Education

✅ You understand what execution is (and why it matters)  
✅ You know the 4 pillars of execution (Plan, Build, Review, Ship)  
✅ You can write a PRD that engineers love  
✅ You know how to work with engineering effectively  
✅ You understand agile ceremonies and your role in them  
✅ You know the 5 execution pitfalls to avoid  
✅ You have a mantra that guides everything  

### Your Execution Mantra

> *"Build the simplest thing that could possibly work, ship it, and learn from what happens next."*

### What's Next

This primer gives you the execution framework. Now you're ready to:

1. **Write** your first PRD
2. **Plan** your first sprint
3. **Ship** your first product
4. **Learn** from what happens next

---

## Quick Reference: One-Page Execution Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ONE-PAGE EXECUTION SUMMARY                          │
│                                                                         │
│  EXECUTION = TURNING STRATEGY INTO PRODUCT                             │
│  ─────────────────────────────────────                                 │
│  Plan → Build → Review → Ship                                         │
│                                                                         │
│  4 PILLARS OF EXECUTION:                                               │
│  ────────────────────                                                  │
│  1. Plan (PRD, user stories, sprint planning)                         │
│  2. Build (Work with engineering, unblock)                           │
│  3. Review (QA, UAT, demo)                                            │
│  4. Ship (Deploy, monitor, validate)                                 │
│                                                                         │
│  PRD STRUCTURE:                                                        │
│  ──────────────                                                        │
│  1. Executive Summary                                                 │
│  2. Problem Statement                                                 │
│  3. User Stories (As a/I want/So that)                               │
│  4. Success Metrics                                                   │
│  5. Detailed Requirements                                             │
│  6. Dependencies & Assumptions                                        │
│  7. Out of Scope                                                      │
│                                                                         │
│  USER STORY TEMPLATE:                                                 │
│  ────────────────────                                                 │
│  As a [user], I want [goal], So that [reason]                        │
│                                                                         │
│  AGILE CEREMONIES:                                                    │
│  ────────────────                                                     │
│  • Backlog Refinement (Prioritize)                                   │
│  • Sprint Planning (Commit)                                           │
│  • Daily Standup (Unblock)                                           │
│  • Sprint Review (Validate)                                           │
│  • Sprint Retrospective (Learn)                                      │
│                                                                         │
│  THE EXECUTION MANTRA:                                                │
│  ────────────────────                                                │
│  "Build the simplest thing that could possibly work, ship it,        │
│  and learn from what happens next."                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

*End of Primer 5*

---

## Quick Navigation

**If you're new to execution:** Start with this primer.  
**If you're writing a PRD:** Use the PRD template.  
**If you're working with engineering:** Use the partnership guide.  
**If you're preparing for interviews:** This primer helps with execution questions.  
