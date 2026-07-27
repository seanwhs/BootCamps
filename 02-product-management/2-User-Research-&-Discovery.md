# Part 2: User Research & Discovery

## Core Concept: Finding Problems Worth Solving

In Part 1, we established that a PM's job starts with **discovery**—understanding what problems are worth solving. But how do you actually do that?

Here's a common mistake new PMs make:

> *"I'll just build a feature that users ask for."*

**This is wrong.** And it's costly.

Users don't always know what they need. As Henry Ford famously said: *"If I had asked people what they wanted, they would have said faster horses."*

Instead of asking users for solutions, you need to understand their **underlying problems**. This is the core of user research.

### The Discovery Mindset

Discovery is about **learning before building**. It's cheap to change your mind during discovery. It's expensive to change it during development. It's catastrophic to change it after launch.

```
                      COST OF CHANGE
                              │
                              │
                         $$$$$│  💀 CATASTROPHIC
                              │     (Post-launch fix)
                              │
                         $$$$$│  💸 EXPENSIVE
                              │     (During development)
                              │
                         $$   │  💰 MODERATE
                              │     (During design)
                              │
                         $    │  🎯 CHEAP
                              │     (During discovery)
                              │
                              └──────────────▶
                              Discovery  Design  Dev  Launch
```

### The Discovery Process

Discovery is a structured process. It's not just "talking to users." It's a systematic approach to uncovering truth.

```
┌─────────────────────────────────────────────────────────────────┐
│                     THE DISCOVERY PROCESS                       │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   PHASE 1    │    │   PHASE 2    │    │   PHASE 3    │    │   PHASE 4    │  │
│  │   PLAN &     │───▶│   CONDUCT    │───▶│   SYNTHESIZE │───▶│   VALIDATE   │  │
│  │   RECRUIT    │    │   RESEARCH   │    │   FINDINGS   │    │   PROBLEMS   │  │
│  │              │    │              │    │              │    │              │  │
│  └──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                                                 │
│  • Define goals      • Interviews      • Affinity mapping   • Prototype testing│
│  • Write questions   • Surveys         • Personas          • A/B experiments  │
│  • Find participants • Observations   • JTBD analysis     • Usability tests   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## The Ledgerly Scenario: Discovery Begins

Remember the problem: 80% of users connect their bank accounts, but only 20% are still active after 30 days.

You've been given two weeks to understand why. Here's how you approach it.

### Step 1: Define Your Research Goals

Before talking to anyone, you need to know what you're trying to learn.

**Your research goals for Ledgerly:**

```
GOAL 1: Understand what triggers users to sign up for Ledgerly
        (What problem were they trying to solve?)

GOAL 2: Understand the user experience during onboarding and first 30 days
        (What worked? What was frustrating?)

GOAL 3: Understand why users stop using Ledgerly
        (What was missing? What was too hard? What wasn't valuable?)

GOAL 4: Understand what keeps active users engaged
        (What features do they use most? What value do they perceive?)
```

### Step 2: Write Your Research Questions

Research questions are specific, open-ended questions that help you achieve your goals.

**For Ledgerly, here are your research questions:**

```
Goal 1 Questions (Trigger):
- What was happening in your life when you decided to try Ledgerly?
- What were you hoping Ledgerly would help you with?
- What other tools were you using before Ledgerly? Why weren't they enough?

Goal 2 Questions (Onboarding):
- Walk me through the first time you set up Ledgerly.
- What was easy? What was confusing?
- What did you expect to happen that didn't happen?

Goal 3 Questions (Drop-off):
- Can you tell me about the last time you used Ledgerly?
- What prevented you from opening it again?
- What would have made you come back?

Goal 4 Questions (Retention):
- What is the most valuable thing Ledgerly does for you?
- How often do you check Ledgerly, and what triggers those visits?
- What would disappoint you if we removed Ledgerly tomorrow?
```

### Step 3: Recruit Participants

You need to talk to real users. For Ledgerly, you'll recruit three groups:

| Group | Criteria | Why |
|-------|----------|-----|
| **Churned Users** | Signed up >45 days ago, haven't used in 30+ days | They have the problems we need to solve |
| **Active Users** | Signed up >45 days ago, still using weekly | They know what works |
| **Drop-off Users** | Started onboarding but never connected a bank account | They can tell us why the first hurdle is too high |

**Recruitment Approach:**

```markdown
## Email to Churned Users

Subject: Help us improve Ledgerly (and get a $20 gift card)

Hi [Name],

You signed up for Ledgerly a few months ago, and we'd love to learn more about your experience—especially if you stopped using it.

We're looking for 15-minute interviews to understand how we can make Ledgerly more valuable. Everyone who participates will receive a $20 Amazon gift card as a thank you.

If you're interested, click here to schedule a time: [Calendly link]

Thanks,
[Your Name]
PM at Ledgerly
```

---

## Framework Deep Dive: The Art of User Interviews

User interviews are the most powerful discovery tool. But they're also easy to do wrong.

### The Right Way vs. The Wrong Way

| Wrong Question | Right Question | Why |
|----------------|----------------|-----|
| "Would you use a budgeting feature?" | "How do you currently track your spending?" | Avoids hypotheticals; reveals actual behavior |
| "What features do you want?" | "What frustrates you about managing your money?" | Focuses on problems, not solutions |
| "Do you find Ledgerly easy to use?" | "Walk me through the last time you used Ledgerly." | Shows actual behavior, not self-reported opinions |
| "Is it important to you to save money?" | "What's the last financial goal you set for yourself?" | Avoids socially desirable answers |

### The 80/20 Rule of Interviewing

```
80% LISTENING         20% ASKING
│                        │
│  • Let users talk     │ • Ask open-ended questions
│  • Don't interrupt    │ • Probe deeper ("Tell me more")
│  • Take notes         │ • Paraphrase back ("So what I'm hearing is...")
│  • Watch for emotion  │ • Keep the conversation flowing
```

### The Interview Script Template

Here's the exact script you'll use for your Ledgerly interviews:

```markdown
# Ledgerly User Research Interview Script

## Introduction (2 minutes)

Hi [Name], thanks so much for taking the time to talk with me today.

I'm [Your Name], a product manager at Ledgerly. I'm responsible for understanding how our users experience the product and what we can do to make it more valuable.

This conversation will take about 15 minutes. I want to be clear: there are no wrong answers. You can't hurt my feelings. My only goal is to understand your experience honestly.

Everything you tell me is confidential. We'll use your feedback to shape what we build next. Do you have any questions before we begin?

---

## Background (3 minutes)

**Q1:** Can you tell me a bit about yourself and your financial situation?
   - *Probe: What do you do for work? How do you typically manage your personal finances?*

**Q2:** What made you decide to try Ledgerly in the first place?
   - *Probe: What was happening in your life at that time? What problem were you hoping Ledgerly would solve?*

---

## The Ledgerly Experience (5 minutes)

**Q3:** Walk me through the first time you set up Ledgerly.
   - *Probe: What was easy? What was confusing? What did you expect to happen that didn't happen?*

**Q4:** Tell me about the last time you used Ledgerly. What were you trying to do?
   - *Probe: Did you accomplish what you wanted? What happened?*

**Q5:** What would make you open Ledgerly more often?
   - *Probe: Imagine it's a week from now. What would have happened that would make you open the app?*

---

## Challenges & Friction (3 minutes)

**Q6:** What's the most frustrating thing about managing your money?
   - *Probe: Tell me more about that experience. How does it make you feel?*

**Q7:** Think about your experience with Ledgerly. What was the most frustrating part?
   - *Probe: What did you expect to happen that didn't happen?*

**Q8:** If you could change one thing about Ledgerly, what would it be?
   - *Probe: Why does that matter to you?*

---

## Closing (2 minutes)

**Q9:** Is there anything else you'd like to share about your experience with Ledgerly?

**Q10:** Would you be open to us following up with you about future research?

---

**Thank them:** Great, that's incredibly helpful. We'll review your feedback with the team and use it to make Ledgerly better. Thanks again for your time!
```

---

## Hands-On Exercise: Research Synthesis

After conducting 6-10 interviews (or reviewing provided interview data), you need to synthesize your findings.

### Step 1: Create an Affinity Map

An **affinity map** is a visual tool for organizing qualitative research data into themes.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AFFINITY MAP                                    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │   THEME: Onboarding is too hard                                 │   │
│  │  ┌─────────────────────────────────────────────────────────┐   │   │
│  │  │ "I didn't know which bank to select."                   │   │   │
│  │  │ "I tried to connect my bank but it said it couldn't."   │   │   │
│  │  │ "I don't remember my banking password."                 │   │   │
│  │  └─────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │   THEME: Missing budgeting features                             │   │
│  │  ┌─────────────────────────────────────────────────────────┐   │   │
│  │  │ "I could see what I spent, but not what I could spend." │   │   │
│  │  │ "I want to know if I'm saving enough."                   │   │   │
│  │  │ "I use a separate spreadsheet for budgeting."            │   │   │
│  │  └─────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │   THEME: No motivation to return                                │   │
│  │  ┌─────────────────────────────────────────────────────────┐   │   │
│  │  │ "I opened it and it said the same thing as yesterday."   │   │   │
│  │  │ "I don't get notifications about anything useful."       │   │   │
│  │  │ "I don't see how it helps me improve."                   │   │   │
│  │  └─────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Step 2: Create Your Ledgerly Affinity Map

Create a document called `affinity-map.md` in your `01-discovery/` folder:

```markdown
# Ledgerly Discovery: Affinity Map

## Research Data
- **Total Interviews:** [X]
- **Churned Users:** [X]
- **Active Users:** [X]
- **Drop-off Users:** [X]

## Themes

### Theme 1: Onboarding is too hard

**Quotes:**
- "I didn't know which bank to select."
- "I tried to connect my bank but it said it couldn't."
- "I don't remember my banking password."

**Insights:**
- Users are confused during account connection
- Technical issues with Plaid integration create friction
- Password management is a barrier for many users

**Impact:**
Users who complete onboarding successfully are 3x more likely to retain, but only 60% successfully connect a bank account on their first attempt.

### Theme 2: Missing budgeting features

**Quotes:**
- "I could see what I spent, but not what I could spend."
- "I want to know if I'm saving enough."
- "I use a separate spreadsheet for budgeting."

**Insights:**
- Ledgerly is currently "read-only"—it shows past spending but doesn't help with future planning
- Users are willing to invest time in a budgeting tool, but Ledgerly doesn't provide one
- Active users are the ones who have found a workaround (external tools)

**Impact:**
Users who set up a budget (via external tools) are 3x more likely to retain. This suggests budgeting is a retention driver.

### Theme 3: No motivation to return

**Quotes:**
- "I opened it and it said the same thing as yesterday."
- "I don't get notifications about anything useful."
- "I don't see how it helps me improve."

**Insights:**
- The app doesn't create "habit loops"—there's no reason to check regularly
- Users want to see progress toward goals, not just raw data
- Notifications are generic and don't provide value

**Impact:**
Without a reason to return, users forget about the app. Retention drops sharply after 30 days.
```

### Step 3: Create User Personas

A **persona** is a fictional representation of a user segment, based on research data. Personas help teams empathize with users and make decisions.

Create a document called `personas.md` in your `01-discovery/` folder:

```markdown
# Ledgerly User Personas

## Persona 1: The Budget Novice - "Sarah"

**Demographics:**
- Age: 26
- Occupation: Marketing Coordinator
- Location: San Francisco, CA
- Income: $65,000/year

**Financial Situation:**
- Just started her first "real" job after college
- Has student loans and credit card debt
- Wants to save but doesn't know how

**Goals & Motivations:**
- "I want to understand where my money is going."
- "I want to save enough for a vacation next year."
- "I don't want to feel guilty about spending."

**Frustrations:**
- "I tried budgeting apps but they're too complicated."
- "I don't understand financial jargon."
- "I feel anxious when I think about money."

**Behavior Patterns:**
- Checks Ledgerly once a week
- Uses the "spending by category" view
- Has never set up a budget

**Pain Points:**
- Doesn't understand how to use budgeting features
- Feels overwhelmed by financial information
- Doesn't see a clear path to improvement

---

## Persona 2: The Financially Savvy User - "Marcus"

**Demographics:**
- Age: 34
- Occupation: Software Engineer
- Location: Austin, TX
- Income: $130,000/year

**Financial Situation:**
- Married, no children
- Has a mortgage and investment portfolio
- Actively manages his finances

**Goals & Motivations:**
- "I want to optimize my savings rate."
- "I want to track my net worth."
- "I want to find ways to reduce unnecessary expenses."

**Frustrations:**
- "I don't want to do this manually in a spreadsheet."
- "I want to see everything in one place."
- "Most apps don't give me enough detail."

**Behavior Patterns:**
- Checks Ledgerly daily
- Uses transaction search and categorization
- Exports data to a personal spreadsheet

**Pain Points:**
- Ledgerly doesn't have advanced features like investment tracking
- Categorization sometimes mislabels transactions
- Can't set custom spending alerts

---

## Persona 3: The Drop-off User - "Emily"

**Demographics:**
- Age: 29
- Occupation: Nurse
- Location: Chicago, IL
- Income: $75,000/year

**Financial Situation:**
- Single parent of one child
- Has a 401(k) but no other savings
- Uses cash often because it's "easier"

**Goals & Motivations:**
- "I want to save for my child's education."
- "I want to get out of credit card debt."
- "I don't want to worry about money all the time."

**Frustrations:**
- "I'm too busy to manage my finances."
- "I tried connecting my bank but it didn't work."
- "I don't trust apps with my financial data."

**Behavior Patterns:**
- Signed up for Ledgerly but never connected a bank account
- Got stuck during onboarding and gave up

**Pain Points:**
- Technical issues prevented her from setting up the app
- She doesn't understand how the app can help her
- She has low trust in financial apps
```

### Step 4: Create a Problem Statement

A **problem statement** is a concise description of the problem you're solving. It's the foundation of your product strategy.

Create a document called `problem-statements.md` in your `01-discovery/` folder:

```markdown
# Ledgerly: Problem Statements

## Primary Problem Statement

Young professionals (ages 25-40) who want to improve their financial health are frustrated by personal finance apps that are either too complex to use or too simple to be useful. Ledgerly provides a basic spending view, but users need help setting financial goals, staying motivated, and seeing progress—and without this, 80% of users stop using the app within 30 days.

**Our problem:** Users connect their banks but don't stay engaged because Ledgerly doesn't help them set and achieve financial goals.

---

## Supporting Problem Statements

### Problem 1: Onboarding Friction
40% of users who start onboarding never connect a bank account. Technical barriers, unclear instructions, and password management issues prevent users from getting started.

### Problem 2: Missing Goal-Setting Features
Users who have a clear financial goal (e.g., "save for a vacation") are more likely to stay engaged. Ledgerly doesn't help users define or track goals.

### Problem 3: No Motivation to Return
Users don't receive value from checking Ledgerly regularly. Without notifications, progress tracking, or "habit loops," users forget about the app after the initial excitement wears off.

### Problem 4: Feature Gaps
Users who need budgeting, goal tracking, or investment features have to use multiple tools. Ledgerly doesn't meet their advanced needs, causing them to churn to competitors.
```

---

## Expert Pro Tips: Discovery Done Right

### Tip 1: Quantity Matters Less Than Quality

You don't need 100 interviews to find patterns. Often, 6-10 interviews will reveal the most important themes.

**The Saturation Principle:** Keep interviewing until you stop hearing new things. When you hear the same patterns repeated, you've reached saturation.

### Tip 2: Look for What's Missing

Users will tell you what frustrates them. But they won't always tell you what's missing—because they don't know what's possible.

**What to look for:**
- "I wish I could..." (That's a feature gap)
- "I have to use this other tool..." (That's a feature gap)
- "I would have liked..." (That's a feature gap)

### Tip 3: Don't Fall in Love with Your Hypotheses

You'll go into interviews with assumptions. That's fine. But be ready to be wrong.

**The Rule:** If 3 users prove your hypothesis wrong, discard it. The data is telling you something.

### Tip 4: Always End with "What Else?"

The most valuable insight often comes in the last minute of the interview. After your final question, ask:

> "Is there anything else you'd like to share that we haven't covered?"

Then stay silent. Let them fill the space.

---

## The Bigger Picture: Where Part 2 Fits in Your Portfolio

The work you've done in Part 2 is the foundation of everything else in this series.

### What You've Accomplished:

✅ **You understand the discovery process:** Planning, conducting, synthesizing, validating  
✅ **You've conducted research (simulated)**: You have interview data and synthesized findings  
✅ **You've created personas:** You understand who your users are  
✅ **You've written problem statements:** You know what problems you're solving  

### What's Coming Next:

In **Part 3: Jobs-to-Be-Done Framework**, we'll deepen our understanding of user problems. You'll learn how to uncover the "jobs" users are hiring your product to do—and how that insight drives product decisions.

### How This Connects:

The personas and problem statements from Part 2 will directly feed into your Jobs-to-Be-Done analysis. You'll use these artifacts to identify the functional, emotional, and social jobs your users need to accomplish.

---

## Verification: Part 2 Completion Checklist

Before moving to Part 3, ensure you've completed the following:

- [ ] Read and understood the core concept: Discovery process
- [ ] Reviewed the Ledgerly research goals and questions
- [ ] Created your `affinity-map.md` in `01-discovery/`
- [ ] Created your `personas.md` in `01-discovery/`
- [ ] Created your `problem-statements.md` in `01-discovery/`
- [ ] Committed your work to your portfolio repository

---

## Part 2 Summary: Key Takeaways

| Concept | Key Insight |
|---------|-------------|
| **Discovery** | Understanding problems before building solutions |
| **Research Goals** | Define what you need to learn before talking to users |
| **Research Questions** | Open-ended questions that avoid hypotheticals |
| **Affinity Mapping** | Organizing qualitative data into themes |
| **Personas** | Fictional representations of user segments |
| **Problem Statements** | Concise descriptions of the problem you're solving |
| **Saturation** | Stop interviewing when you stop hearing new things |

---

## Self-Check: Quick Knowledge Test

**1. Why is discovery cheaper than development?**

<details>
<summary>Click to reveal answer</summary>

Because it's easier to change your mind during discovery. A wrong assumption discovered during discovery costs little to correct. A wrong assumption discovered during development can cost thousands or millions to fix.
</details>

**2. What's wrong with this interview question: "Would you use a budgeting feature?"**

<details>
<summary>Click to reveal answer</summary>

It's hypothetical. Users will often say "yes" to features they'd never actually use. Better to ask: "How do you currently track your spending?" to understand actual behavior.
</details>

**3. What is the saturation principle in user research?**

<details>
<summary>Click to reveal answer</summary>

Keep interviewing until you stop hearing new insights. When patterns repeat across interviews, you've reached saturation and have enough data to make decisions.
</details>

**4. What's the difference between a persona and a problem statement?**

<details>
<summary>Click to reveal answer</summary>

A persona describes *who* the user is (demographics, goals, frustrations). A problem statement describes *what* problem you're solving for that user.
</details>

---

## Looking Ahead: Prepare for Part 3

Before the next part, take a moment to reflect:

- Which of the Ledgerly personas do you most relate to? Why?
- What jobs do you "hire" your favorite apps to do?
- How do you measure success in your own financial goals?

In Part 3, we'll explore the Jobs-to-Be-Done framework—a powerful tool for understanding user motivation.
