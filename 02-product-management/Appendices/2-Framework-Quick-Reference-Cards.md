# Appendix 2: Framework Quick Reference Cards

## Overview

This appendix provides concise, one-page reference cards for all the key frameworks used throughout the series. Use these as a quick memory jogger during interviews, portfolio reviews, or when applying frameworks to your own products.

**Purpose:** To provide a "cheat sheet" of the most important PM frameworks in a scannable, referenceable format.

---

## Framework 1: Jobs-to-Be-Done (JTBD)

### The Core Question
> *"What job is the user hiring your product to do?"*

### The Three Job Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│  FUNCTIONAL JOB    │  EMOTIONAL JOB     │  SOCIAL JOB                 │
│  ────────────────  │  ───────────────   │  ───────────────            │
│  What the user     │  How the user      │  How the user               │
│  wants to          │  wants to feel     │  wants to be perceived      │
│  accomplish        │                    │                             │
│                    │                    │                             │
│  Example:          │  Example:          │  Example:                   │
│  "Track my         │  "Feel in control  │  "Be seen as financially    │
│   spending"        │   of my finances"  │   responsible"              │
└─────────────────────────────────────────────────────────────────────────┘
```

### The Job Map

```
1. DEFINE PROBLEM → 2. GATHER INFO → 3. ANALYZE → 4. MAKE PLAN → 5. EXECUTE & TRACK
   (Friction)         (Friction)       (Friction)   (Friction)    (Friction)
```

### JTBD Canvas

```
┌───────────────────────┬───────────────────────────────────────────┐
│   USER PROFILE        │   VALUE PROPOSITION                      │
│                       │                                           │
│  Jobs to Be Done:     │   Products & Services:                   │
│  • [Job 1]            │   • [What you're building]               │
│  • [Job 2]            │                                           │
│                       │   Pain Relievers:                        │
│  Pains:               │   • [How you reduce frustration]         │
│  • [Pain 1]           │                                           │
│  • [Pain 2]           │   Gain Creators:                         │
│                       │   • [How you deliver outcomes]           │
│  Gains:               │                                           │
│  • [Gain 1]           │                                           │
│  • [Gain 2]           │                                           │
└───────────────────────┴───────────────────────────────────────────┘
```

**JTBD Statement Template:**
> "When [circumstance], I want to [functional job] so I can [emotional/social outcome]."

**Example:**
> "When I feel overwhelmed by my finances, I want to easily track my spending so I can feel in control of my money."

---

## Framework 2: RICE Scoring

### The Formula

```
┌─────────────────────────────────────────────────────────────────────────┐
│  RICE SCORE = (REACH × IMPACT × CONFIDENCE) ÷ EFFORT                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  REACH                                                         │   │
│  │  Number of users affected in a given time period               │   │
│  │  Example: 50,000 users = 50,000 reach                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  IMPACT                                                        │   │
│  │  3 = Massive (transforms the product)                          │   │
│  │  2 = High (significant improvement)                            │   │
│  │  1 = Medium (moderate improvement)                             │   │
│  │  0.5 = Low (minor improvement)                                 │   │
│  │  0.25 = Minimal (hardly noticeable)                            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  CONFIDENCE                                                    │   │
│  │  100% = High (data-driven)                                     │   │
│  │  80% = Medium (some data)                                      │   │
│  │  50% = Low (guesswork)                                         │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  EFFORT                                                        │   │
│  │  Person-months or story points                                 │   │
│  │  Example: 2 person-months of engineering time = 2 effort       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### When to Use RICE
- **When:** Comparing features for prioritization
- **Why:** Provides a quantitative, defensible score
- **Limitation:** Requires estimates (confident can vary)

### Quick Example

| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| Goal Setting | 50,000 | 3 | 85% | 2 | 63,750 |
| Weekly Summaries | 40,000 | 2 | 75% | 1 | 60,000 |
| Onboarding | 20,000 | 3 | 90% | 1 | 54,000 |

---

## Framework 3: Kano Model

### The Four Categories

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     KANO MODEL CATEGORIES                               │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  BASIC FEATURES (Table Stakes)                                  │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Must-have; absence causes dissatisfaction                   │   │
│  │  • Users expect these; they don't delight                     │   │
│  │  • Example: Account aggregation, security, login              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  PERFORMANCE FEATURES (More is Better)                          │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Satisfaction increases linearly with quality                │   │
│  │  • More features = more satisfied users                        │   │
│  │  • Example: Budgeting, goal setting, progress tracking        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  EXCITEMENT FEATURES (Delighters)                               │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Unexpected; delight users                                   │   │
│  │  • Differentiate from competitors                              │   │
│  │  • Example: Actionable insights, gamification, weekly summaries│   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  INDIFFERENT FEATURES                                           │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  • Don't significantly affect satisfaction                    │   │
│  │  • Can be de-prioritized                                       │   │
│  │  • Example: Niche features, "nice to have"                    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Visual Map

```
               SATISFACTION
                    ▲
                    │
           EXCITEMENT│
           FEATURES  │
                    │      PERFORMANCE
                    │      FEATURES
                    │      ↗
                    │   ┌──────────┐
                    │   │          │
          ──────────┼───│──────────│──────────▶ FEATURE
                    │   │          │      FUNCTIONALITY
                    │   └──────────┘
                    │      ↘
                    │      BASIC
                    │      FEATURES
                    │
                    │
```

### When to Use Kano
- **When:** Understanding user expectations
- **Why:** Helps identify differentiators vs. table stakes
- **Limitation:** Subjective; requires user input

---

## Framework 4: Outcome-Based Prioritization

### The Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Step 1: Define Key Outcomes                                           │
│  ───────────────────────────────────────────────────────────────────── │
│  What are the most important business metrics?                        │
│  • Increase retention                                                 │
│  • Increase activation                                                │
│  • Increase revenue                                                   │
│                                                                         │
│  Step 2: Map Features to Outcomes                                      │
│  ───────────────────────────────────────────────────────────────────── │
│  Which features drive which outcomes?                                 │
│  • Goal Setting → Retention                                           │
│  • Onboarding → Activation                                            │
│                                                                         │
│  Step 3: Prioritize by Impact on Outcomes                              │
│  ───────────────────────────────────────────────────────────────────── │
│  Which features have the biggest impact on top outcomes?              │
│                                                                         │
│  Step 4: Consider Effort                                               │
│  ───────────────────────────────────────────────────────────────────── │
│  Which high-impact features can we build quickly?                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Impact Matrix

| Feature | Retention | Activation | Revenue | Total Impact | Effort | Priority |
|---------|-----------|------------|---------|--------------|--------|----------|
| Goal Setting | ★★★ | ★★★ | ★ | 7 | 2 | 1 |
| Onboarding | ★★ | ★★★ | ★ | 6 | 1 | 2 |
| Weekly Summaries | ★★★ | ★ | ★ | 5 | 1 | 3 |
| Insights | ★★ | ★★★ | ★★ | 7 | 2 | 4 |

### When to Use Outcome-Based
- **When:** Aligning features with business goals
- **Why:** Ensures you're building what matters
- **Limitation:** Requires clear business outcomes

---

## Framework 5: The Strategy Pyramid

### The Levels

```
                    ┌─────────────────────────────────────┐
                    │          PRODUCT VISION             │
                    │   "The North Star: Where we         │
                    │    are ultimately going."           │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │        PRODUCT STRATEGY             │
                    │   "The path: How we'll get          │
                    │    there, and why."                 │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │        PRODUCT ROADMAP              │
                    │   "The steps: What we'll build,     │
                    │    in what order, and when."        │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │        PRODUCT BACKLOG              │
                    │   "The details: The specific        │
                    │    features we'll build next."      │
                    └─────────────────────────────────────┘
```

### When to Use
- **When:** Defining product direction
- **Why:** Provides clarity and alignment
- **Limitation:** Requires stakeholder buy-in

---

## Framework 6: The Value Proposition Canvas

### The Canvas

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     VALUE PROPOSITION CANVAS                            │
│                                                                         │
│  ┌────────────────────────────┐    ┌──────────────────────────────┐   │
│  │       USER PROFILE         │    │     VALUE PROPOSITION        │   │
│  │                            │    │                              │   │
│  │  ┌────────────────────┐   │    │  ┌────────────────────────┐  │   │
│  │  │  JOBS TO BE DONE    │   │    │  │  PAIN RELIEVERS        │  │   │
│  │  │  • What is the user │   │    │  │  • How we reduce       │  │   │
│  │  │    trying to        │   │◄───│  │    user frustration    │  │   │
│  │  │    accomplish?      │   │    │  │                        │  │   │
│  │  └────────────────────┘   │    │  └────────────────────────┘  │   │
│  │                            │    │                              │   │
│  │  ┌────────────────────┐   │    │  ┌────────────────────────┐  │   │
│  │  │  PAINS             │   │    │  │  GAIN CREATORS         │  │   │
│  │  │  • What frustrates │   │◄───│  │  • How we help users   │  │   │
│  │  │    the user?       │   │    │  │    achieve their goals │  │   │
│  │  └────────────────────┘   │    │  └────────────────────────┘  │   │
│  │                            │    │                              │   │
│  │  ┌────────────────────┐   │    │  ┌────────────────────────┐  │   │
│  │  │  GAINS             │   │    │  │  PRODUCTS & SERVICES   │  │   │
│  │  │  • What outcomes   │   │    │  │  • What we're building │  │   │
│  │  │    does the user   │   │◄───│  │    to deliver value    │  │   │
│  │  │    want?           │   │    │  │                        │  │   │
│  │  └────────────────────┘   │    │  └────────────────────────┘  │   │
│  └────────────────────────────┘    └──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### When to Use
- **When:** Defining your product's value
- **Why:** Aligns value with user needs
- **Limitation:** Requires user research

---

## Framework 7: The AARRR Framework (Pirate Metrics)

### The Funnel

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE AARRR FRAMEWORK                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ACQUISITION                                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  How do users find you?                                        │   │
│  │  • Organic search, referrals, ads, social media               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ACTIVATION                                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Do users have a "wow" moment?                                 │   │
│  │  • Connect bank, see spending, set first goal                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  RETENTION                                                     │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Do users come back?                                          │   │
│  │  • Day 1, 7, 30 retention; frequency; churn rate              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  REFERRAL                                                      │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Do users tell others?                                        │   │
│  │  • Viral coefficient; referral rate; word of mouth            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  REVENUE                                                       │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Are users paying?                                            │   │
│  │  • ARPU, LTV, conversion rate                                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### When to Use
- **When:** Understanding user journey
- **Why:** Provides a complete view of user lifecycle
- **Limitation:** Can be complex to track all metrics

---

## Framework 8: The Growth Pyramid

### The Pyramid

```
                         ┌─────────────┐
                         │   REVENUE   │   ▲
                         │  (Monetize) │   │
                         └─────────────┘   │
                                ▲          │
                         ┌─────────────┐   │
                         │  RETENTION  │   │
                         │  (Keep)     │   │
                         └─────────────┘   │
                                ▲          │
                         ┌─────────────┐   │
                         │ ACTIVATION  │   │
                         │  (WOW)      │   │
                         └─────────────┘   │
                                ▲          │
                         ┌─────────────┐   │
                         │ACQUISITION  │   │
                         │ (Find)      │   │
                         └─────────────┘   │
                                │          │
                                └──────────┘
```

### Key Principle
> **Growth is built from the bottom up.**
> 1. First, make sure you have product-market fit (retention)
> 2. Then, optimize activation (users experience value)
> 3. Then, scale acquisition (bring more users in)
> 4. Finally, optimize revenue (monetize)

### When to Use
- **When:** Planning growth strategy
- **Why:** Prioritizes correctly (retention before acquisition)
- **Limitation:** Simple; requires deeper analysis

---

## Framework 9: The Product Lifecycle

### The Cycle

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   PHASE 1    │    │   PHASE 2    │    │   PHASE 3    │    │   PHASE 4    │
│  MINDSET &   │───▶│  STRATEGY &  │───▶│  EXECUTION & │───▶│  GROWTH &    │
│  DISCOVERY   │    │ PRIORITIZATION│    │  DELIVERY    │    │  ITERATION   │
│              │    │              │    │              │    │              │
│  • User      │    │  • Strategy  │    │  • PRD       │    │  • Metrics   │
│    Research  │    │  • Vision    │    │  • User      │    │  • Analytics │
│  • Personas  │    │  • Roadmap   │    │    Stories   │    │  • Growth    │
│  • JTBD      │    │  • Backlog   │    │  • Sprint    │    │  • Iteration │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
```

### Key Questions

| Phase | Question |
|-------|----------|
| Discovery | Are we solving the right problem? |
| Strategy | What should we build and why? |
| Execution | How do we build it right? |
| Growth | Did it work? How do we make it better? |

### When to Use
- **When:** Structuring product work
- **Why:** Provides a complete framework for product management
- **Limitation:** Iterative; phases overlap in practice

---

## Framework 10: The Experiment Runbook

### Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│  1. IDEATE          2. DESIGN         3. RUN         4. ANALYZE      5. ACT│
│  ──────────────    ──────────────    ────────────   ──────────────  ──────────│
│  • Identify        • Define         • Launch       • Analyze        • Implement│
│    hypothesis      control/test     • Monitor      • Determine      • Deploy   │
│  • Define          • Sample size    • Ensure        significance    • Iterate  │
│    experiment      • Design          data quality   • Document       • Learn   │
│  • Set success     • Create                      • Share findings            │
│    criteria          experiment                                             │
└─────────────────────────────────────────────────────────────────────────┘
```

### Experiment Template

```
┌─────────────────────────────────────────────────────────────────────────┐
│  EXPERIMENT: [Name]                                                    │
│                                                                         │
│  Objective: [What we want to achieve]                                  │
│  Hypothesis: [If we do X, then Y will happen]                         │
│  Control: [Current experience]                                        │
│  Test: [New experience]                                               │
│                                                                         │
│  Primary Metric: [Metric we're optimizing]                            │
│  Secondary Metrics: [Other metrics]                                   │
│  Timeline: [X weeks]                                                  │
│  Sample Size: [X users]                                               │
│  Significance: [p < 0.05]                                             │
│                                                                         │
│  Results:                                                              │
│  • Control: [Metric value]                                            │
│  • Test: [Metric value]                                               │
│  • Significant: [Yes/No]                                              │
│                                                                         │
│  Decision: [Implement / Iterate / Discard]                            │
└─────────────────────────────────────────────────────────────────────────┘
```

### When to Use
- **When:** Running product experiments
- **Why:** Provides a structured approach to learning
- **Limitation:** Requires data and resources

---

## Framework Comparison Matrix

| Framework | Best For | When to Use | Complexity |
|-----------|----------|-------------|------------|
| **JTBD** | Understanding users | Discovery phase | Medium |
| **RICE** | Prioritization | Strategy phase | Medium |
| **Kano** | Feature categorization | Strategy phase | Low |
| **Outcome-Based** | Aligning with goals | Strategy phase | Medium |
| **Strategy Pyramid** | Defining direction | Strategy phase | Low |
| **Value Proposition** | Defining value | Strategy phase | Medium |
| **AARRR** | Understanding user journey | Growth phase | High |
| **Growth Pyramid** | Prioritizing growth | Growth phase | Low |
| **Product Lifecycle** | Structuring work | All phases | Low |
| **Experiment Runbook** | Running experiments | Growth phase | Medium |

---

## Quick Start Guide

### For Discovery Phase
1. **JTBD:** Understand what users are trying to accomplish
2. **Value Proposition:** Define how you'll deliver value
3. **Personas:** Understand who your users are

### For Strategy Phase
1. **Strategy Pyramid:** Define vision → strategy → roadmap → backlog
2. **RICE:** Prioritize features quantitatively
3. **Kano:** Understand user expectations
4. **Outcome-Based:** Align with business goals

### For Execution Phase
1. **PRD:** Document requirements
2. **User Stories:** Define specific needs
3. **Agile:** Work with engineering

### For Growth Phase
1. **AARRR:** Understand user lifecycle
2. **Growth Pyramid:** Prioritize growth efforts
3. **Experiment Runbook:** Test hypotheses
4. **Metrics Dashboard:** Track progress

---

## Quick Reference Summary

### Key Definitions

| Term | Definition |
|------|------------|
| **North Star Metric** | Single metric capturing core product value |
| **RICE** | Reach × Impact × Confidence ÷ Effort |
| **JTBD** | Jobs-to-Be-Done framework |
| **PRD** | Product Requirements Document |
| **NPS** | Net Promoter Score |
| **ARPU** | Average Revenue Per User |
| **LTV** | Lifetime Value |
| **CAC** | Customer Acquisition Cost |

### Key Ratios

| Ratio | What It Measures |
|-------|------------------|
| **DAU/MAU** | User engagement (stickiness) |
| **LTV/CAC** | Unit economics (sustainability) |
| **NPS** | User satisfaction (loyalty) |
| **Retention Rate** | User loyalty (stickiness) |

### Key Questions

| Phase | Key Question |
|-------|--------------|
| Discovery | "What job is the user hiring?" |
| Strategy | "What should we build and why?" |
| Execution | "How do we build it right?" |
| Growth | "Did it work? How do we improve?" |

---

*End of Appendix 2*
