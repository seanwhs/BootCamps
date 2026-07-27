# Part 6: Prioritization Frameworks

## Core Concept: Making Tough Trade-offs

You've defined your vision, crafted your strategy, and analyzed the competition. Now comes the hardest part of product management: **deciding what to build first.**

Here's the reality:

> *"You have 100 ideas and time to build 10. Your job is to choose the 10 that deliver the most value."*

Prioritization is the art of making trade-offs explicit. It's how you turn strategy into a concrete roadmap. It's also how you defend your decisions to stakeholders.

### The Prioritization Problem

Every product team faces the same challenge:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE PRIORITIZATION PROBLEM                          │
│                                                                         │
│                        ┌──────────────────┐                             │
│                        │   100 IDEAS      │                             │
│                        │   (Features,     │                             │
│                        │    Improvements, │                             │
│                        │    Fixes)        │                             │
│                        └────────┬─────────┘                             │
│                                 │                                        │
│                                 ▼                                        │
│                        ┌──────────────────┐                             │
│                        │   TEAM CAPACITY  │                             │
│                        │   (Time, People, │                             │
│                        │    Money)        │                             │
│                        └────────┬─────────┘                             │
│                                 │                                        │
│                                 ▼                                        │
│                        ┌──────────────────┐                             │
│                        │   10 IDEAS       │                             │
│                        │   (What we       │                             │
│                        │    actually      │                             │
│                        │    build)        │                             │
│                        └──────────────────┘                             │
│                                                                         │
│  THE QUESTION: How do we choose the right 10?                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why Frameworks Matter

Without a framework, prioritization becomes:
- **Political:** The loudest stakeholder wins
- **Emotional:** The "coolest" idea wins
- **Random:** We just build whatever's next

With a framework, prioritization becomes:
- **Transparent:** Everyone understands why decisions were made
- **Defensible:** You can explain your choices to stakeholders
- **Consistent:** You make similar decisions over time
- **Strategic:** You prioritize what matters most

---

## The Ledgerly Scenario: Time to Prioritize

### The Feature Candidates

Based on our discovery and strategy work, here are the features we're considering for Ledgerly:

| Feature | Description | Why It's Considered |
|---------|-------------|---------------------|
| **F1: Goal Setting** | Users set savings, budgeting, or debt reduction goals | 3x retention uplift; key user need from JTBD |
| **F2: Progress Tracking** | Visual dashboards showing goal progress | Users need to see improvement; habit formation |
| **F3: Actionable Insights** | Personalized recommendations ("You spent $50 on coffee this week") | Guidance gap; key differentiator |
| **F4: Weekly Summaries** | Email or push summary of weekly spending | Habit formation; motivation to return |
| **F5: Improved Onboarding** | Simplified bank connection, better error handling | 40% drop-off in onboarding; high impact |
| **F6: Budget Creation** | Users create monthly budgets with visual bars | Core budgeting need; missing feature |
| **F7: Category Customization** | Users edit transaction categories | Data accuracy; user control |
| **F8: Investment Tracking** | Track stocks, retirement accounts, and net worth | Advanced user need; competitive parity |
| **F9: Bill Tracking** | Users see upcoming bills and get reminders | Convenience; retention driver |
| **F10: Gamification** | Achievements, streaks, and rewards for financial habits | Engagement; habit formation |

### The Dilemma

You only have capacity for 4-5 features in the next quarter. How do you choose?

Let's apply prioritization frameworks to make this decision.

---

## Framework Deep Dive: Three Prioritization Frameworks

### Framework 1: RICE Scoring

**RICE** stands for **Reach, Impact, Confidence, Effort**. It's one of the most widely used prioritization frameworks.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        RICE SCORING                                    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  REACH                                                          │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  How many users will this feature affect in a given time       │   │
│  │  period? (e.g., per quarter)                                   │   │
│  │                                                                 │   │
│  │  Example: 50,000 users = 50,000 reach                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  IMPACT                                                         │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  How much will this feature improve the user experience?       │   │
│  │                                                                 │   │
│  │  3 = Massive impact (transforms the product)                   │   │
│  │  2 = High impact (significant improvement)                     │   │
│  │  1 = Medium impact (moderate improvement)                      │   │
│  │  0.5 = Low impact (minor improvement)                          │   │
│  │  0.25 = Minimal impact (hardly noticeable)                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  CONFIDENCE                                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  How sure are you about your estimates?                       │   │
│  │                                                                 │   │
│  │  100% = High confidence (data-driven)                          │   │
│  │  80% = Medium confidence (some data)                           │   │
│  │  50% = Low confidence (guesswork)                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  EFFORT                                                         │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  How much time/effort will this take from the team?           │   │
│  │                                                                 │   │
│  │  Measured in "person-months" or "story points"                │   │
│  │  Example: 1 month of engineering time = 1 effort               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  RICE SCORE = (Reach × Impact × Confidence) ÷ Effort          │   │
│  │                                                                 │   │
│  │  The higher the score, the higher the priority.               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Framework 2: Kano Model

The **Kano Model** categorizes features based on how they affect customer satisfaction.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         KANO MODEL                                      │
│                                                                         │
│                       SATISFACTION                                       │
│                           ▲                                             │
│                           │                                             │
│                  EXCITEMENT  │                                          │
│                  FEATURES   │                                           │
│                  ("Delight")│            ┌──────────────┐              │
│                           │             │    ATTRACTIVE │              │
│                           │            ┌┴──────────────┴┐             │
│                           │           │  "Wow, I love  │              │
│                           │           │   this!"       │              │
│                           │           └────────────────┘              │
│                           │                                             │
│                 ┌─────────┼─────────────────────────┐                  │
│                 │  PERFORMANCE FEATURES              │                  │
│                 │  ("More is better")                │                  │
│                 │  ┌──────────────────────────────┐  │                  │
│                 │  │  "This is good, but I expect │  │                  │
│                 │  │   it to get better over time"│  │                  │
│                 │  └──────────────────────────────┘  │                  │
│                 │                                     │                  │
│                 └─────────────────────────────────────┘                  │
│                           │                                             │
│                           │           ┌────────────────────┐           │
│                           │           │    BASIC FEATURES  │           │
│                           │           │    ("Table stakes")│           │
│                           │           │  ┌────────────────┐ │           │
│                           │           │  │ "I expect this │ │           │
│                           │           │  │  to be here"   │ │           │
│              ────────────┼───────────│  └────────────────┘ │           │
│                           │           └────────────────────┘           │
│                           │                                             │
│                           │                                             │
│                           └─────────────────────────────────────────────▶
│                                                                  FEATURE │
│                                                            FUNCTIONALITY │
│                                                                         │
│  Basic Features: Must-have; their absence causes dissatisfaction        │
│  Performance Features: More is better; linear satisfaction             │
│  Excitement Features: Delighters; unexpected value                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Framework 3: Outcome-Based Prioritization

**Outcome-Based Prioritization** focuses on business outcomes rather than features. You prioritize features that drive the biggest business impact.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    OUTCOME-BASED PRIORITIZATION                          │
│                                                                         │
│  1. Define Key Outcomes                                                │
│     ─────────────────────────────────────────────────────────────────   │
│     What are the most important business metrics?                      │
│     • Increase user retention by 15%                                  │
│     • Increase user activation by 20%                                 │
│     • Increase user goal-completion by 25%                            │
│                                                                         │
│  2. Map Features to Outcomes                                            │
│     ─────────────────────────────────────────────────────────────────   │
│     Which features drive which outcomes?                               │
│     • Goal Setting → Increases retention (3x uplift)                  │
│     • Improved Onboarding → Increases activation (reduces drop-off)    │
│     • Weekly Summaries → Increases retention (habit formation)         │
│                                                                         │
│  3. Prioritize by Impact on Outcomes                                    │
│     ─────────────────────────────────────────────────────────────────   │
│     Which features have the biggest impact on our top outcomes?        │
│                                                                         │
│  4. Consider Effort                                                     │
│     ─────────────────────────────────────────────────────────────────   │
│     Which high-impact features can we build quickly?                   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Hands-On Exercise: Prioritize Ledgerly's Features

### Step 1: RICE Scoring

Create a document called `rice-scoring.md` in your `02-strategy/` folder:

```markdown
# Ledgerly: RICE Scoring

## Methodology
Features scored on Reach (users affected per quarter), Impact (1-3 scale), Confidence (%), and Effort (person-months).

**RICE Score = (Reach × Impact × Confidence) ÷ Effort**

---

## Feature 1: Goal Setting
- **Reach:** 50,000 users (50,000)
- **Impact:** 3 (Massive - core to retention)
- **Confidence:** 85% (strong research evidence)
- **Effort:** 2 person-months
- **RICE Score:** (50,000 × 3 × 0.85) ÷ 2 = **63,750**

## Feature 2: Progress Tracking
- **Reach:** 50,000 users (50,000)
- **Impact:** 2 (High - drives engagement)
- **Confidence:** 80% (good research evidence)
- **Effort:** 1.5 person-months
- **RICE Score:** (50,000 × 2 × 0.80) ÷ 1.5 = **53,333**

## Feature 3: Actionable Insights
- **Reach:** 50,000 users (50,000)
- **Impact:** 2 (High - key differentiator)
- **Confidence:** 70% (some research evidence)
- **Effort:** 2 person-months
- **RICE Score:** (50,000 × 2 × 0.70) ÷ 2 = **35,000**

## Feature 4: Weekly Summaries
- **Reach:** 40,000 users (not all users check weekly)
- **Impact:** 2 (High - habit formation)
- **Confidence:** 75% (moderate evidence)
- **Effort:** 1 person-month
- **RICE Score:** (40,000 × 2 × 0.75) ÷ 1 = **60,000**

## Feature 5: Improved Onboarding
- **Reach:** 20,000 users (drop-off users per quarter)
- **Impact:** 3 (Massive - unblocks users)
- **Confidence:** 90% (strong evidence from research)
- **Effort:** 1 person-month
- **RICE Score:** (20,000 × 3 × 0.90) ÷ 1 = **54,000**

## Feature 6: Budget Creation
- **Reach:** 40,000 users (those who want to budget)
- **Impact:** 2 (High - core budgeting need)
- **Confidence:** 80% (good research evidence)
- **Effort:** 2 person-months
- **RICE Score:** (40,000 × 2 × 0.80) ÷ 2 = **32,000**

## Feature 7: Category Customization
- **Reach:** 30,000 users (power users)
- **Impact:** 1 (Medium - nice to have)
- **Confidence:** 70% (some evidence)
- **Effort:** 1 person-month
- **RICE Score:** (30,000 × 1 × 0.70) ÷ 1 = **21,000**

## Feature 8: Investment Tracking
- **Reach:** 15,000 users (advanced users only)
- **Impact:** 1 (Medium - niche need)
- **Confidence:** 60% (limited evidence)
- **Effort:** 3 person-months
- **RICE Score:** (15,000 × 1 × 0.60) ÷ 3 = **3,000**

## Feature 9: Bill Tracking
- **Reach:** 35,000 users (convenience value)
- **Impact:** 1 (Medium - nice to have)
- **Confidence:** 65% (moderate evidence)
- **Effort:** 2 person-months
- **RICE Score:** (35,000 × 1 × 0.65) ÷ 2 = **11,375**

## Feature 10: Gamification
- **Reach:** 30,000 users (engagement)
- **Impact:** 1 (Medium - engagement)
- **Confidence:** 50% (limited evidence)
- **Effort:** 2 person-months
- **RICE Score:** (30,000 × 1 × 0.50) ÷ 2 = **7,500**

---

## RICE Prioritization (Highest to Lowest)

| Rank | Feature | RICE Score | Why |
|------|---------|------------|-----|
| 1 | Goal Setting | 63,750 | Massive impact on retention; strong evidence |
| 2 | Weekly Summaries | 60,000 | High impact on habit formation; low effort |
| 3 | Improved Onboarding | 54,000 | Unblocks 40% of users; high confidence |
| 4 | Progress Tracking | 53,333 | Drives engagement and retention |
| 5 | Actionable Insights | 35,000 | Key differentiator; moderate effort |
| 6 | Budget Creation | 32,000 | Core budgeting need; higher effort |
| 7 | Category Customization | 21,000 | Power user feature; low impact |
| 8 | Bill Tracking | 11,375 | Convenience feature; limited evidence |
| 9 | Gamification | 7,500 | Speculative; limited evidence |
| 10 | Investment Tracking | 3,000 | Niche; high effort |

## Decision: Top 5 Features to Build

Based on RICE scoring, the top 5 features to build next are:
1. Goal Setting
2. Weekly Summaries
3. Improved Onboarding
4. Progress Tracking
5. Actionable Insights
```

### Step 2: Kano Model Analysis

Create a document called `kano-model.md` in your `02-strategy/` folder:

```markdown
# Ledgerly: Kano Model Analysis

## Feature Categorization

### Basic Features (Table Stakes)
*Features users expect; absence causes dissatisfaction*

- **Account Aggregation:** Users expect to connect their bank accounts. This is non-negotiable.
- **Transaction Categorization:** Users expect spending to be categorized automatically.
- **Secure Login:** Users expect their data to be secure.

**Implication:** These must work flawlessly. Investment is required for maintenance and reliability.

### Performance Features (More is Better)
*Features where satisfaction increases linearly with quality*

- **Budget Creation:** Better budgeting tools = more satisfied users.
- **Progress Tracking:** Better visualization and tracking = more engaged users.
- **Goal Setting:** More robust goals = more committed users.

**Implication:** These should be the focus of continuous improvement. Invest here for maximum ROI.

### Excitement Features (Delighters)
*Unexpected features that surprise and delight users*

- **Actionable Insights:** Users don't expect personalized financial guidance. This is a differentiator.
- **Weekly Summaries:** Users don't expect regular, helpful check-ins. This builds habit.
- **Gamification:** Users don't expect "fun" from a finance app. This creates delight.

**Implication:** These differentiate Ledgerly from competitors. Prioritize them to stand out.

### Indifferent Features
*Features that don't significantly affect satisfaction*

- **Investment Tracking:** Only relevant for a subset of advanced users.
- **Bill Tracking:** Convenient but not core to the main job.

**Implication:** De-prioritize these until later.

---

## Kano Insights

### Key Insight 1: Basic Features Must Be Perfect
If account aggregation fails or categorization is wrong, users will churn. These are not differentiators—they are prerequisites.

**Action:** Ensure Plaid integration is reliable and categorization is accurate.

### Key Insight 2: Performance Features Drive Retention
Features like Goal Setting and Progress Tracking directly correlate with retention. Investing here pays off.

**Action:** Make Goal Setting a core feature. Build Progress Tracking to show users they're improving.

### Key Insight 3: Excitement Features Differentiate
Actionable Insights and Weekly Summaries are unexpected gifts. They surprise users and create loyalty.

**Action:** Prioritize these to build a unique brand experience.

### Key Insight 4: Delight Without Overwhelm
Don't add so many excitement features that the product becomes confusing. Simplicity is a basic feature.

**Action:** Balance innovation with clarity.
```

### Step 3: Outcome-Based Prioritization

Create a document called `outcome-prioritization.md` in your `02-strategy/` folder:

```markdown
# Ledgerly: Outcome-Based Prioritization

## Key Outcomes (From Strategy)

1. **Increase User Retention:** Current retention is 20% at 30 days. Goal: 40% by end of quarter.
2. **Increase User Activation:** Current activation is 60% (users who connect a bank). Goal: 75%.
3. **Increase Goal-Completion:** Current users with goals have 3x retention. Goal: 50% of users set goals.
4. **Build Habit Formation:** Users who check Ledgerly weekly retain at 5x rate. Goal: 30% weekly active users.

## Feature Impact on Outcomes

| Feature | Retention | Activation | Goal-Completion | Habit Formation | Total Impact |
|---------|-----------|------------|-----------------|-----------------|--------------|
| Goal Setting | ★★★ | ★★★ | ★★★ | ★★★ | 12 |
| Progress Tracking | ★★★ | ★★ | ★★★ | ★★★ | 11 |
| Weekly Summaries | ★★★ | ★ | ★★ | ★★★ | 9 |
| Improved Onboarding | ★★ | ★★★ | ★ | ★ | 7 |
| Actionable Insights | ★★ | ★★★ | ★★ | ★★ | 9 |
| Budget Creation | ★★ | ★★ | ★★★ | ★★ | 9 |
| Category Customization | ★ | ★ | ★ | ★ | 4 |
| Investment Tracking | ★ | ★ | ★ | ★ | 4 |
| Bill Tracking | ★ | ★ | ★ | ★ | 4 |
| Gamification | ★★ | ★★ | ★ | ★★★ | 8 |

**Legend:**
- ★★★ = High impact on this outcome
- ★★ = Medium impact on this outcome
- ★ = Low impact on this outcome

---

## Outcome-Based Priorities

### Priority 1: Goal Setting
**Why:** Highest total impact. Directly drives retention, activation, and goal-completion.
**Outcome:** Users who set goals are 3x more likely to retain.

### Priority 2: Progress Tracking
**Why:** Drives retention and habit formation. Users need to see progress to stay motivated.
**Outcome:** Users who track progress are 2x more likely to remain engaged.

### Priority 3: Weekly Summaries
**Why:** Builds habit formation. Keeps Ledgerly top-of-mind.
**Outcome:** Users who receive weekly summaries are 2x more likely to be weekly active.

### Priority 4: Actionable Insights
**Why:** Drives activation and retention. Guides users on what to do next.
**Outcome:** Users who receive personalized guidance are 2x more likely to take action.

### Priority 5: Improved Onboarding
**Why:** Unblocks 40% of users who currently churn during onboarding.
**Outcome:** Higher activation rate.

---

## Final Prioritization Decision

Based on RICE Scoring, Kano Model, and Outcome-Based Prioritization:

### Top 5 Features to Build Next

1. **Goal Setting** (RICE: #1, Kano: Performance, Outcome: #1)
   - Why: Directly drives retention and user success
   - Effort: 2 person-months

2. **Improved Onboarding** (RICE: #3, Kano: Basic, Outcome: #2)
   - Why: Unblocks 40% of potential users
   - Effort: 1 person-month

3. **Progress Tracking** (RICE: #4, Kano: Performance, Outcome: #3)
   - Why: Drives engagement and habit formation
   - Effort: 1.5 person-months

4. **Weekly Summaries** (RICE: #2, Kano: Excitement, Outcome: #4)
   - Why: Builds habits; low effort
   - Effort: 1 person-month

5. **Actionable Insights** (RICE: #5, Kano: Excitement, Outcome: #5)
   - Why: Differentiator; guides users
   - Effort: 2 person-months

**Total Effort:** 7.5 person-months (within 1 quarter capacity)
```

### Step 4: Create the Prioritized Backlog

Create a document called `prioritized-backlog.md` in your `02-strategy/` folder:

```markdown
# Ledgerly: Prioritized Backlog

## Quarter Goals

1. Increase user retention from 20% to 40% at 30 days
2. Increase user activation from 60% to 75%
3. Ensure 50% of users set at least one financial goal
4. Build habit formation: 30% weekly active users

---

## Backlog Items (Prioritized)

### Epic 1: Goal Setting (Priority 1)
**User Stories:**
- As a user, I want to set a savings goal so I can see progress toward my target
- As a user, I want to set a spending goal so I can manage my expenses
- As a user, I want to set a debt reduction goal so I can plan to become debt-free
- As a user, I want to see my goal progress on my dashboard so I stay motivated
- As a user, I want to be notified when I'm on track (or off track) for my goals

**Acceptance Criteria:**
- Users can create, edit, and delete goals
- Goals have a target amount, timeline, and category
- Progress is automatically tracked based on transactions
- Dashboard shows goal progress visually

**Effort:** 2 person-months

---

### Epic 2: Improved Onboarding (Priority 2)
**User Stories:**
- As a user, I want to easily connect my bank account without technical issues
- As a user, I want clear guidance on what to do if bank connection fails
- As a user, I want to understand the value of connecting before I do it
- As a user, I want to set my first goal during onboarding

**Acceptance Criteria:**
- Plaid integration is reliable with clear error handling
- Users who fail connection receive troubleshooting guidance
- Users see value proposition before connecting
- At least one goal is suggested during onboarding

**Effort:** 1 person-month

---

### Epic 3: Progress Tracking (Priority 3)
**User Stories:**
- As a user, I want to see my net worth over time
- As a user, I want to see my spending trends
- As a user, I want to see how I'm progressing toward my goals
- As a user, I want to see "before and after" comparisons

**Acceptance Criteria:**
- Dashboard shows key metrics: net worth, spending, and goal progress
- Trends are shown over time (1 month, 3 months, 6 months)
- Visual charts are clear and easy to understand

**Effort:** 1.5 person-months

---

### Epic 4: Weekly Summaries (Priority 4)
**User Stories:**
- As a user, I want to receive a weekly summary of my spending
- As a user, I want to see my goal progress in the summary
- As a user, I want actionable tips in my summary

**Acceptance Criteria:**
- Weekly email or push notification delivered
- Summary includes: total spending, goal progress, and top insights
- Users can customize notification frequency

**Effort:** 1 person-month

---

### Epic 5: Actionable Insights (Priority 5)
**User Stories:**
- As a user, I want to receive personalized insights about my finances
- As a user, I want to know what I can do to improve my financial health
- As a user, I want to see "wins" when I make progress

**Acceptance Criteria:**
- Insights are generated based on user transaction data
- Insights are personalized to each user's situation
- Insights include: "You spent $50 on coffee this week. Try reducing to $30."
- Positive reinforcement is included: "You've saved 10% more this month!"

**Effort:** 2 person-months

---

## Backlog Summary

| Priority | Epic | Effort | Outcome Impact |
|----------|------|--------|----------------|
| 1 | Goal Setting | 2 months | Retention, Activation, Goal-Completion |
| 2 | Improved Onboarding | 1 month | Activation, Retention |
| 3 | Progress Tracking | 1.5 months | Retention, Habit Formation |
| 4 | Weekly Summaries | 1 month | Habit Formation, Retention |
| 5 | Actionable Insights | 2 months | Activation, Retention, Guidance |

**Total Quarter Effort:** 7.5 person-months (within capacity)

---

## Future Considerations

**Next Quarter Candidates:**
- Budget Creation
- Category Customization
- Bill Tracking
- Gamification

**Long-Term Candidates:**
- Investment Tracking
- Advanced Reporting
- Financial Education Content
```

---

## Expert Pro Tips: Prioritization Done Right

### Tip 1: Prioritize the "Boring" Stuff

Technical debt, bug fixes, and infrastructure improvements aren't exciting. But they're essential. If you only build features, your product will become unstable and slow to iterate.

**Rule of Thumb:** Allocate 20-30% of your capacity to maintenance and technical debt.

### Tip 2: Be Ruthless About "Not Now"

Every feature you don't build in this quarter is still a candidate for next quarter. But if you're not ruthlessly pruning, you'll never finish anything.

**The 80/20 Rule:** The top 20% of features deliver 80% of the value. Focus there.

### Tip 3: Involve Your Team

Prioritization isn't a solo activity. Involve your engineering and design teams. They'll have insights about effort, feasibility, and alternative solutions that you won't have.

### Tip 4: Revisit Priorities Quarterly

The world changes. Your priorities should too. Revisit your backlog quarterly and adjust based on:
- New user insights
- Changing market conditions
- Competitor moves
- Technical progress

### Tip 5: Don't Fall in Love with Your Framework

RICE is great. Kano is great. But no framework is perfect. Use them as tools, not gospel. Ultimately, you need to use your judgment—and your frameworks should *inform* your judgment, not replace it.

---

## The Bigger Picture: Where Part 6 Fits in Your Portfolio

This is the final part of Phase 2: Strategy & Prioritization. You've now completed the strategic work.

### What You've Accomplished:

✅ **You've prioritized your backlog:** You know exactly what to build and in what order  
✅ **You've applied multiple frameworks:** RICE, Kano, and Outcome-Based Prioritization  
✅ **You've created a roadmap:** The top 5 features for the next quarter  

### What's Coming Next:

In **Part 7: Writing PRDs**, we transition from *strategy* to *execution*. You'll learn how to write a Product Requirements Document—the blueprint for engineering to build your features.

### How This Connects:

Your prioritized backlog from Part 6 will be the input for Part 7. You'll take the top-priority feature (Goal Setting) and write a complete PRD for it.

---

## Verification: Part 6 Completion Checklist

Before moving to Part 7, ensure you've completed the following:

- [ ] Completed RICE scoring for all features
- [ ] Completed Kano Model analysis
- [ ] Completed Outcome-Based Prioritization
- [ ] Created your prioritized backlog
- [ ] Created all documents in your `02-strategy/` folder
- [ ] Committed your work to your portfolio repository

---

## Part 6 Summary: Key Takeaways

| Concept | Key Insight |
|---------|-------------|
| **RICE Scoring** | Reach × Impact × Confidence ÷ Effort |
| **Kano Model** | Basic, Performance, and Excitement features |
| **Outcome-Based** | Prioritize features by business impact |
| **Prioritized Backlog** | The ranked list of what to build next |
| **80/20 Rule** | 20% of features deliver 80% of value |

---

## Self-Check: Quick Knowledge Test

**1. What are the four components of RICE scoring?**

<details>
<summary>Click to reveal answer</summary>

Reach (number of users affected), Impact (1-3 scale), Confidence (%), Effort (person-months or story points).
</details>

**2. What's the difference between Basic and Excitement features in the Kano Model?**

<details>
<summary>Click to reveal answer</summary>

Basic features are expected; their absence causes dissatisfaction. Excitement features are unexpected; their presence delights users. Basic features are prerequisites; excitement features are differentiators.
</details>

**3. Why is Outcome-Based Prioritization useful?**

<details>
<summary>Click to reveal answer</summary>

It connects features directly to business outcomes. Instead of prioritizing based on what's "cool" or "interesting," you prioritize based on what drives measurable business impact.
</details>

**4. What's the 80/20 rule in prioritization?**

<details>
<summary>Click to reveal answer</summary>

The top 20% of features deliver 80% of the value. Focus on the high-impact features and don't get distracted by the long tail.
</details>

---

## Phase 2 Complete: What You've Built

Congratulations! You've completed Phase 2: Strategy & Prioritization. Here's what you now have in your portfolio:

```
02-strategy/
├── product-vision.md          # Where you're going
├── value-proposition.md       # How you deliver value
├── competitive-positioning.md # How you're different
├── feature-comparison.md      # Feature-by-feature comparison
├── swot-analysis.md           # Strengths, Weaknesses, Opportunities, Threats
├── positioning-map.md         # Visual competitive comparison
├── strategic-insights.md      # What to do based on analysis
├── rice-scoring.md           # RICE analysis of all features
├── kano-model.md             # Kano categorization
├── outcome-prioritization.md # Outcome-based analysis
└── prioritized-backlog.md    # The final prioritized list
```

You've moved from understanding the problem to defining the solution. You know exactly what you're building and why.

---

## Looking Ahead: Prepare for Part 7

Before the next part, take a moment to consider:

- What should a PRD include?
- How do you write requirements that engineers can build from?
- How do you balance completeness with conciseness?

In Part 7, we'll answer these questions as we write a complete Product Requirements Document for the top-priority feature.
