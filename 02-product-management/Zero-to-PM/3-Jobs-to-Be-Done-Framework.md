# Part 3: Jobs-to-Be-Done Framework

## Core Concept: Why People "Hire" Your Product

In Part 2, we learned about user research and discovery. We created personas and problem statements. Now we're going to go deeper.

Here's a fundamental shift in thinking:

> *Instead of asking "Who is our user?" ask "What job is our user hiring our product to do?"*

This is the **Jobs-to-Be-Done (JTBD)** framework—one of the most powerful mental models in product management.

### The JTBD Metaphor

Imagine you're at a hardware store. You see a customer buying a 3/4-inch drill bit.

**Traditional thinking:** "This customer wants a 3/4-inch drill bit."  
**JTBD thinking:** "This customer wants a 3/4-inch hole."

The drill bit is the *solution*. The hole is the *job*. 

When you understand the job (the hole), you can explore different solutions. Maybe you don't need a drill bit. Maybe you need a different tool entirely. Maybe you don't need a hole at all—you need to hang a picture, and there are better ways to do that.

### What Is a "Job"?

A "job" is the progress a person wants to make in a particular circumstance. It's not just a task—it's an outcome with emotional weight.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         THE JTBD FRAMEWORK                              │
│                                                                         │
│  A "job" has three components:                                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  FUNCTIONAL JOB: What the user is trying to accomplish        │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Example: "I need to know if I'm saving enough money."        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  EMOTIONAL JOB: How the user wants to feel                     │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Example: "I want to feel confident about my finances."       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SOCIAL JOB: How the user wants to be perceived                │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Example: "I want to be seen as financially responsible."     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why JTBD Matters for PMs

JTBD helps you avoid the "solution trap." Instead of asking "What features should we build?" you ask:

> *"What job is the user trying to get done?"*

This shifts your focus from *what* to build to *why* it matters. And that's where great products are born.

---

## The Ledgerly Scenario: Applying JTBD

Remember our problem: 80% of users churn within 30 days. We need to understand *why* people "hire" Ledgerly—and why they "fire" it.

### Step 1: Identify the Jobs

From our user research in Part 2, we can identify the jobs different users are hiring Ledgerly to do:

| Persona | Functional Job | Emotional Job | Social Job |
|---------|---------------|---------------|------------|
| **Sarah (Budget Novice)** | "Help me understand where my money is going." | "I want to feel less anxious about my finances." | "I want to be seen as someone who has their act together." |
| **Marcus (Financially Savvy)** | "Help me optimize my savings and track net worth." | "I want to feel in control of my financial life." | "I want to be seen as financially successful." |
| **Emily (Drop-off User)** | "Help me save for my child's education." | "I want to stop worrying about money." | "I want to be a good parent who provides for their child." |

### Step 2: Identify the "Job Map"

A **job map** breaks down a job into a step-by-step process. This helps you see where users get stuck.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     LEDGERLY JOB MAP                                   │
│              "Get control of my personal finances"                     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Step 1: DEFINE THE PROBLEM                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  User realizes: "I don't know where my money is going."       │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  📍 FRICTION POINT: Users don't know what questions to ask    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Step 2: GATHER INFORMATION                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  User connects bank accounts, imports transactions            │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  📍 FRICTION POINT: Technical issues, password complexity     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Step 3: ANALYZE THE DATA                                      │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  User reviews spending categories, identifies patterns        │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  📍 FRICTION POINT: Data is presented as raw numbers, not      │   │
│  │     actionable insights                                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Step 4: MAKE A PLAN                                          │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  User sets budget, defines savings goals                      │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  📍 FRICTION POINT: Ledgerly doesn't have goal-setting tools  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Step 5: EXECUTE AND TRACK PROGRESS                           │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  User monitors spending against budget, adjusts habits        │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  📍 FRICTION POINT: No feedback loop, no habit formation      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Step 3: The "Switch" Analysis

People "hire" a product when it helps them make progress. But they also "fire" it when it doesn't meet their expectations.

The **Switch Analysis** examines why users choose Ledgerly over competitors—and why they leave.

```markdown
## Why Users "Hire" Ledgerly

**The Circumstance:**
- Users are frustrated with their current financial situation
- They want to feel in control but don't know how
- Traditional banking tools are confusing and not helpful

**The New Solution (Ledgerly):**
- "See all your accounts in one place"
- "Understand your spending with simple categories"
- "Free to use"

**The Competing Solutions (What They Were Doing Before):**
- Spreadsheets (too much manual work)
- Banking apps (don't provide insights)
- Other budgeting apps (too complex, too expensive)

**The "Switch" Decision:**
Users "hire" Ledgerly because they believe it will make financial management easier and less anxiety-inducing.

---

## Why Users "Fire" Ledgerly

**The Circumstance:**
- Users aren't getting the expected value
- The app doesn't help them make progress
- They forget about it because there's no reason to return

**The "Firing" Triggers:**
- Onboarding fails (40% of users)
- No visible progress (app doesn't show improvement)
- No "habit loop" (no reason to check regularly)
- Competitors offer more features (budgeting, goals, investments)

**The Outcome:**
Users "fire" Ledgerly and either:
- Return to their previous solution (spreadsheets, banking apps)
- Try a competitor (Mint, YNAB, Personal Capital)
- Give up on financial management entirely (least desirable for user and business)
```

---

## Framework Deep Dive: The Jobs-to-Be-Done Canvas

The **JTBD Canvas** is a tool to systematically analyze the jobs your users are hiring your product to do. You'll create one for Ledgerly.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     JOBS-TO-BE-DONE CANVAS                              │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  1. THE FUNCTIONAL JOB                                         │   │
│  │  ────────────────────────────────────────────────────────────── │   │
│  │  What is the specific task the user is trying to accomplish?   │   │
│  │                                                                 │   │
│  │  "Users want to understand, manage, and improve their personal │   │
│  │   finances without having to use multiple tools or spend       │   │
│  │   hours on manual data entry."                                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  2. THE EMOTIONAL JOB                                           │   │
│  │  ────────────────────────────────────────────────────────────── │   │
│  │  How does the user want to feel while accomplishing this job?  │   │
│  │                                                                 │   │
│  │  "Users want to feel:                                          │   │
│  │   - In control of their finances                              │   │
│  │   - Confident about their financial decisions                 │   │
│  │   - Less anxious about money                                  │   │
│  │   - Proud of their financial progress"                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  3. THE SOCIAL JOB                                              │   │
│  │  ────────────────────────────────────────────────────────────── │   │
│  │  How does the user want to be perceived by others?             │   │
│  │                                                                 │   │
│  │  "Users want to be seen as:                                    │   │
│  │   - Financially responsible                                   │   │
│  │   - Someone who has their life together                       │   │
│  │   - A good provider (for their family)"                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  4. THE USER'S CURRENT SOLUTION                                │   │
│  │  ────────────────────────────────────────────────────────────── │   │
│  │  What is the user currently doing to accomplish this job?      │   │
│  │                                                                 │   │
│  │  "Users currently use:                                         │   │
│  │   - Spreadsheets (manual, time-consuming)                     │   │
│  │   - Banking apps (limited insights)                           │   │
│  │   - Competitors (Mint, YNAB)                                  │   │
│  │   - Nothing (avoiding the problem)"                           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  5. THE FRICTION POINTS                                        │   │
│  │  ────────────────────────────────────────────────────────────── │   │
│  │  What frustrates the user about their current solution?        │   │
│  │                                                                 │   │
│  │  "Users are frustrated by:                                     │   │
│  │   - Manual data entry (time-consuming)                        │   │
│  │   - No help setting financial goals                           │   │
│  │   - No guidance on improving                                  │   │
│  │   - Technical issues connecting accounts"                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  6. THE SUCCESS METRICS                                        │   │
│  │  ────────────────────────────────────────────────────────────── │   │
│  │  How does the user measure progress toward completing the job? │   │
│  │                                                                 │   │
│  │  "Users measure success by:                                    │   │
│  │   - Seeing their net worth increase                           │   │
│  │   - Hitting their savings goals                               │   │
│  │   - Reducing financial anxiety                                │   │
│  │   - Feeling in control of their finances"                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Hands-On Exercise: Complete the JTBD Analysis

You'll create a JTBD Canvas for Ledgerly, incorporating all the insights from our research.

### Step 1: Create Your JTBD Canvas

Create a document called `jobs-to-be-done.md` in your `01-discovery/` folder:

```markdown
# Ledgerly: Jobs-to-Be-Done Analysis

## Overview

This document applies the Jobs-to-Be-Done framework to Ledgerly, analyzing why users "hire" and "fire" the product.

**Job Statement:** Users "hire" Ledgerly to help them understand, manage, and improve their personal finances with minimal effort and anxiety.

---

## The Job Map

### Step 1: Define the Problem
Users realize they don't know where their money is going.

*Friction Point:* Users don't know what questions to ask.

### Step 2: Gather Information
Users connect bank accounts and import transactions.

*Friction Point:* Technical issues, password complexity, trust concerns.

### Step 3: Analyze the Data
Users review spending categories to identify patterns.

*Friction Point:* Data is presented as raw numbers, not actionable insights.

### Step 4: Make a Plan
Users set a budget or define savings goals.

*Friction Point:* Ledgerly lacks goal-setting and budgeting features.

### Step 5: Execute and Track Progress
Users monitor spending against their plan and adjust habits.

*Friction Point:* No feedback loop, no habit formation, no motivation to return.

---

## The JTBD Canvas

### 1. The Functional Job
*What is the specific task the user is trying to accomplish?*

Users want to understand, manage, and improve their personal finances without having to use multiple tools or spend hours on manual data entry.

### 2. The Emotional Job
*How does the user want to feel while accomplishing this job?*

Users want to feel:
- In control of their finances
- Confident about their financial decisions
- Less anxious about money
- Proud of their financial progress
- Empowered to make positive changes

### 3. The Social Job
*How does the user want to be perceived by others?*

Users want to be seen as:
- Financially responsible
- Someone who has their life together
- A good provider (for their family)
- Successful and in control

### 4. The User's Current Solution
*What is the user currently doing to accomplish this job?*

Users currently use:
- **Spreadsheets:** Manual, time-consuming, error-prone
- **Banking apps:** Limited insights, no help with planning
- **Competitors:** Mint (free, but ads-focused), YNAB (paid, but excellent for budgeting), Personal Capital (good for investments, but too complex)
- **Nothing:** Many users simply avoid the problem

### 5. The Friction Points
*What frustrates the user about their current solution?*

Users are frustrated by:
- Manual data entry (takes too much time)
- No help setting financial goals (they don't know where to start)
- No guidance on improving (they don't know what to do differently)
- Technical issues connecting accounts (they give up)
- Too much complexity (they feel overwhelmed)
- Not enough guidance (they feel lost)

### 6. The Success Metrics
*How does the user measure progress toward completing the job?*

Users measure success by:
- Seeing their net worth increase
- Hitting their savings goals
- Reducing their financial anxiety
- Feeling in control of their finances
- Understanding where their money is going

---

## Why Users "Hire" Ledgerly

### The Circumstance
Users are frustrated with their current financial situation. Traditional banking tools don't help them understand their spending, and other solutions are too complex or time-consuming.

### The "Switch" Decision
Users "hire" Ledgerly because they believe it will:
- Make financial management easy (automatic transaction import)
- Help them understand their spending (clear categories)
- Reduce financial anxiety (visualize their finances)
- Be free (no upfront cost)

### The Competing Solutions (What They Were Doing Before)
- Spreadsheets (too much manual work)
- Banking apps (don't provide insights)
- No solution (avoiding the problem)

---

## Why Users "Fire" Ledgerly

### The "Firing" Triggers
Users "fire" Ledgerly when:
1. **Onboarding fails:** Technical issues prevent them from getting started
2. **No visible progress:** They don't see improvement in their finances
3. **No habit loop:** There's no reason to check the app regularly
4. **Missing key features:** They need budgeting, goals, or investment tracking
5. **Competitors offer more:** Other apps meet their needs better

### The Outcome
Users "fire" Ledgerly and:
- Return to their previous solution (spreadsheets, banking apps)
- Try a competitor (Mint, YNAB, Personal Capital)
- Give up on financial management entirely (unmet need)

---

## JTBD Insights: What This Means for Ledgerly

### Insight 1: The "Job" is Financial Confidence
Users don't just want to see their spending. They want to feel in control. The emotional job is as important as the functional job.

**Implication:** Ledgerly needs to help users feel progress, not just see numbers.

### Insight 2: Users "Fire" Because They Don't See Improvement
The #1 reason users churn is that they don't see their financial situation improving.

**Implication:** Ledgerly needs to show progress over time. Users need to see a positive trend in their net worth, savings, or spending.

### Insight 3: The App Doesn't Create a Habit
Users forget about Ledgerly because there's no reason to check it regularly.

**Implication:** Ledgerly needs habit-forming features: notifications, progress tracking, weekly summaries, and personalized insights.

### Insight 4: Onboarding is the On-Ramp to the Job
If users can't complete onboarding, they can't accomplish the job.

**Implication:** Ledgerly must prioritize fixing onboarding friction. This is the highest-impact investment.

### Insight 5: Goal Setting is the Missing Link
Users who set goals are 3x more likely to retain. Goal setting helps users visualize progress.

**Implication:** Goal-setting features should be a top priority. Start with "savings goals" and "budget goals."
```

### Step 2: Create the JTBD Statement

A **JTBD Statement** is a concise way to express a job. Use the following template:

```
When [circumstance], I want to [functional job] so I can [emotional/social outcome].
```

**For Ledgerly:**

```
When I feel overwhelmed by my finances and don't know where my money is going, 
I want to easily track my spending and understand where I can improve, 
so I can feel in control of my finances and confident about my financial future.
```

Add this statement to your `jobs-to-be-done.md` file.

---

## Expert Pro Tips: JTBD in Practice

### Tip 1: Jobs Are Stable; Solutions Are Not

A job you identified five years ago is likely still relevant. The solution that helps users accomplish that job will change.

**Example:**
- **Job:** "I want to capture and share moments with friends and family."
- **Solutions over time:** Film cameras → Digital cameras → Social media → Messaging apps → Video calls

The job stays the same. The solutions evolve.

### Tip 2: Look for the "Job to Be Done" in Everyday Life

Practice seeing JTBD everywhere:
- Why did I use Uber instead of the bus? (Job: "Get to my destination quickly and comfortably")
- Why did I order delivery instead of cooking? (Job: "Eat without spending time preparing food")
- Why did I buy an overpriced coffee? (Job: "Get a caffeine boost and feel productive")

### Tip 3: Don't Confuse Tasks with Jobs

Tasks are individual steps. Jobs are the larger outcome.

| Task | Job |
|------|-----|
| Connect a bank account | Get a complete view of my finances |
| Categorize a transaction | Understand my spending patterns |
| Set a budget | Save more money |

When you focus on the job, you see the bigger picture.

### Tip 4: Use JTBD to Guide Your Roadmap

Before adding a feature to your roadmap, ask:
> *"What job is this feature helping users accomplish?"*

If you can't articulate the job, the feature probably doesn't need to exist.

---

## The Bigger Picture: Where Part 3 Fits in Your Portfolio

This is the final part of Phase 1: Mindset & Discovery. You've now completed the foundational work.

### What You've Accomplished:

✅ **You've completed the discovery phase:** You have research, personas, problem statements, and JTBD analysis  
✅ **You understand user motivation:** Why users "hire" and "fire" your product  
✅ **You can articulate the "job":** You know what users are trying to accomplish  

### What's Coming Next:

In **Part 4: Product Strategy & Vision**, we transition from *discovery* to *strategy*. You'll define where Ledgerly is going and how you'll get there.

### How This Connects:

Your JTBD analysis directly informs your product strategy. You now know what job users are hiring Ledgerly to do—and what's preventing them from accomplishing it. In Part 4, you'll define a product vision that addresses these insights.

---

## Verification: Part 3 Completion Checklist

Before moving to Part 4, ensure you've completed the following:

- [ ] Read and understood the JTBD framework
- [ ] Completed the Ledgerly job map
- [ ] Completed the JTBD Canvas for Ledgerly
- [ ] Created your `jobs-to-be-done.md` in `01-discovery/`
- [ ] Articulated the JTBD statement
- [ ] Committed your work to your portfolio repository

---

## Part 3 Summary: Key Takeaways

| Concept | Key Insight |
|---------|-------------|
| **Jobs-to-Be-Done** | Focus on what users want to accomplish, not the features they ask for |
| **Job Components** | Functional, emotional, and social jobs |
| **Job Map** | Step-by-step process of accomplishing a job |
| **"Hire" vs. "Fire"** | Why users adopt and abandon products |
| **JTBD Canvas** | Systematic analysis of a user's job |
| **JTBD Statement** | Concise expression: Circumstance + Job + Outcome |

---

## Self-Check: Quick Knowledge Test

**1. What's the difference between a "task" and a "job"?**

<details>
<summary>Click to reveal answer</summary>

A task is a specific action (e.g., "categorize this transaction"). A job is the larger outcome the user wants to achieve (e.g., "understand my spending habits"). Jobs explain *why* tasks matter.
</details>

**2. What are the three components of a job?**

<details>
<summary>Click to reveal answer</summary>

Functional (what the user wants to accomplish), Emotional (how the user wants to feel), and Social (how the user wants to be perceived).
</details>

**3. Why is JTBD better than asking users what features they want?**

<details>
<summary>Click to reveal answer</summary>

Users often can't articulate their true needs. Features are solutions, not problems. JTBD helps you understand the underlying problem, so you can design better solutions.
</details>

**4. What's a key insight from the Ledgerly JTBD analysis?**

<details>
<summary>Click to reveal answer</summary>

Users hire Ledgerly to gain "financial confidence"—not just to see spending data. Users fire it because they don't see progress and don't build habits. Goal-setting is a critical missing feature.
</details>

---

## Phase 1 Complete: What You've Built

Congratulations! You've completed Phase 1: Mindset & Discovery. Here's what you now have in your portfolio:

```
01-discovery/
├── pm-philosophy.md          # Your personal approach to PM
├── affinity-map.md           # Synthesized user research
├── personas.md               # User segments
├── problem-statements.md     # The problems you're solving
└── jobs-to-be-done.md        # JTBD analysis
```

You've established the foundation for everything that follows. You understand who your users are, what problems they have, and what jobs they're trying to accomplish.

---

## Looking Ahead: Prepare for Part 4

Before the next part, take a moment to consider:

- What does "success" look like for Ledgerly in one year?
- What makes Ledgerly different from competitors?
- How would you explain Ledgerly's value in one sentence?

In Part 4, we'll answer these questions as we define Ledgerly's product strategy and vision.
