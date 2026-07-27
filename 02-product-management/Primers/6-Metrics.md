# Primer 6: The Metrics Primer - Measure What Matters

## Overview

This primer is designed for readers who want to master the **metrics and analytics** side of product management. Great PMs don't just build products—they measure whether those products are actually working and use data to drive decisions.

**Purpose:** To give you a complete, actionable framework for choosing, tracking, and acting on product metrics, in 15 minutes.

---

## What This Primer Covers

1. **Why Metrics Matter** (The Data-Driven PM)
2. **The Metrics Hierarchy** (North Star → KPIs → Health Metrics)
3. **The AARRR Framework** (Pirate Metrics Explained)
4. **The Metric Selection Framework** (Choosing the Right Metrics)
5. **The Metrics Dashboard** (How to Track and Visualize)
6. **The 5 Metrics Pitfalls** (And How to Avoid Them)
7. **Your Metrics Mantra** (The One Question That Guides Everything)

---

## 1. Why Metrics Matter

### The 30-Second Definition

> **Metrics are quantitative measures that help you understand whether your product is delivering value, identify areas for improvement, and make data-driven decisions.**

### The Data-Driven PM

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE DATA-DRIVEN PM                                  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  OPINION-DRIVEN PM                                              │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  "I think users want this feature."                            │   │
│  │  "I believe retention is improving."                          │   │
│  │  "I feel like this is the right priority."                    │   │
│  │                                                                 │   │
│  │  ❌ Opinions are subjective and often wrong.                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  DATA-DRIVEN PM                                                │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  "Data shows users who set goals retain at 3x."              │   │
│  │  "Retention increased from 20% to 40% after the feature."    │   │
│  │  "RICE scoring shows Goal Setting is the top priority."      │   │
│  │                                                                 │   │
│  │  ✅ Data is objective and actionable.                         │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why Metrics Matter

1. **Validate assumptions**—Did the feature actually work?
2. **Guide decisions**—What should we build next?
3. **Communicate success**—Show stakeholders you're making progress
4. **Identify problems**—Where are users getting stuck?
5. **Drive accountability**—Are we achieving our goals?

---

## 2. The Metrics Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE METRICS HIERARCHY                               │
│                                                                         │
│                    ┌─────────────────────────────────────┐             │
│                    │        NORTH STAR METRIC            │             │
│                    │   "The ultimate measure of          │             │
│                    │    product value."                  │             │
│                    │   Example: "Weekly Active Users     │             │
│                    │    with a Goal"                     │             │
│                    └──────────────┬──────────────────────┘             │
│                                   │                                     │
│                    ┌──────────────▼──────────────────────┐             │
│                    │          KPIs (Key Performance      │             │
│                    │          Indicators)                │             │
│                    │   "The critical metrics that drive  │             │
│                    │    the North Star."                │             │
│                    │   Example: "Goal Adoption Rate,"   │             │
│                    │   "Day 30 Retention"               │             │
│                    └──────────────┬──────────────────────┘             │
│                                   │                                     │
│                    ┌──────────────▼──────────────────────┐             │
│                    │        HEALTH METRICS               │             │
│                    │   "Metrics that tell you if the     │             │
│                    │    product is healthy."             │             │
│                    │   Example: "NPS," "Crash Rate,"    │             │
│                    │   "Page Load Time"                 │             │
│                    └─────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────────────────┘
```

### North Star Metric

**What It Is:** The single metric that captures the core value your product delivers.

**Characteristics of a Good North Star:**
- Reflects user value
- Is measurable
- Is actionable
- Is leading (predicts future success)
- Is understandable to everyone

**Examples:**
| Product | North Star Metric |
|---------|-------------------|
| Ledgerly | Weekly Active Users with a Goal |
| Airbnb | Nights Booked |
| Spotify | Hours of Music Streamed |
| Slack | Messages Sent |
| Facebook | Daily Active Users |

### KPIs (Key Performance Indicators)

**What They Are:** The critical metrics that drive your North Star.

**Example for Ledgerly:**
- Goal Adoption Rate (leads to WAU with Goal)
- Day 30 Retention (retained users contribute to WAU)
- Activation Rate (more activated users → more goals)

### Health Metrics

**What They Are:** Metrics that tell you if the product is healthy.

**Example for Ledgerly:**
- NPS (user satisfaction)
- Crash Rate (technical health)
- Page Load Time (performance)

---

## 3. The AARRR Framework (Pirate Metrics)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE AARRR FRAMEWORK                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ACQUISITION                                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  How do users find you?                                        │   │
│  │  Metrics: Signups, traffic sources, conversion rate           │   │
│  │  Example: 50,000 signups from organic search in Q3            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ACTIVATION                                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Do users have a "wow" moment?                                 │   │
│  │  Metrics: Activation rate, time to activation                 │   │
│  │  Example: 60% of users connect a bank account                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  RETENTION                                                     │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Do users come back?                                          │   │
│  │  Metrics: Day 1, 7, 30 retention, churn rate                  │   │
│  │  Example: 20% of users are active at Day 30                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  REFERRAL                                                      │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Do users tell others?                                        │   │
│  │  Metrics: Viral coefficient, referral rate                    │   │
│  │  Example: 10% of new users come from referrals                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  REVENUE                                                       │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Are users paying?                                            │   │
│  │  Metrics: ARPU, LTV, conversion rate                          │   │
│  │  Example: $5 ARPU, 5% conversion to premium                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### AARRR in Action: Ledgerly Example

| Stage | Metric | Value | Target |
|-------|--------|-------|--------|
| **Acquisition** | New signups/month | 5,000 | 7,000 |
| **Activation** | Bank connection rate | 60% | 75% |
| **Retention** | Day 30 retention | 20% | 40% |
| **Referral** | Referral rate | 5% | 15% |
| **Revenue** | ARPU | $0 | $2 |

---

## 4. The Metric Selection Framework

### How to Choose the Right Metrics

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     METRIC SELECTION FRAMEWORK                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  1. START WITH YOUR NORTH STAR                                 │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  What metric captures your core value?                         │   │
│  │  → "Weekly Active Users with a Goal"                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  2. IDENTIFY THE DRIVERS                                       │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  What metrics drive your North Star?                          │   │
│  │  → Goal Adoption Rate, Retention Rate, Activation Rate       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  3. TRACK HEALTH METRICS                                      │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  What metrics tell you if the product is healthy?            │   │
│  │  → NPS, Crash Rate, Page Load Time                           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  4. ADD CONTEXTUAL METRICS                                    │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  What metrics help you understand user behavior?             │   │
│  │  → Session Length, Feature Adoption, Funnel Completion       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Metric Selection Checklist

When choosing a metric, ask:

- [ ] Is it aligned with our North Star?
- [ ] Is it measurable (can we track it)?
- [ ] Is it actionable (can we influence it)?
- [ ] Is it understandable (can everyone grasp it)?
- [ ] Is it leading (does it predict future success)?
- [ ] Is it consistent (can we compare over time)?

---

## 5. The Metrics Dashboard

### What a Good Dashboard Looks Like

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     METRICS DASHBOARD EXAMPLE                           │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  QUARTERLY GOALS                                                 │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  │ Metric        │ Current │ Target │ Status │                 │   │
│  │  │ WAU           │ 12,000  │ 18,000 │ 🟡     │                 │   │
│  │  │ North Star    │ 40%     │ 60%    │ 🟢     │                 │   │
│  │  │ Retention     │ 20%     │ 40%    │ 🔴     │                 │   │
│  │  │ Activation    │ 60%     │ 75%    │ 🟡     │                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ACQUISITION FUNNEL                                              │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Landing Page   40,000 ── 100%                                 │   │
│  │  Sign Up        30,000 ── 75%                                  │   │
│  │  Onboarding     28,000 ── 70%                                  │   │
│  │  Bank Connect   18,000 ── 45%                                  │   │
│  │  Set Goal       12,000 ── 30%                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  RETENTION                                                      │   │
│  │  ───────────────────────────────────────────────────────────── │   │
│  │  Day 1:   45%  ████████████████████████████████████░░░░░░░░   │   │
│  │  Day 7:   25%  ████████████████████░░░░░░░░░░░░░░░░░░░░░░░   │   │
│  │  Day 30:  20%  ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░   │   │
│  │                                                                 │   │
│  │  With Goal:   40%  ██████████████████████████████████░░░░░░   │   │
│  │  Without:     12%  ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Dashboard Best Practices

| Do | Don't |
|----|-------|
| Focus on a few key metrics | Track everything (it's noise) |
| Show trends over time | Show only current values |
| Make it visually clear | Make it cluttered |
| Update it regularly | Update it sporadically |
| Share it with the team | Keep it to yourself |
| Use it to drive action | Use it just for reporting |

---

## 6. The 5 Metrics Pitfalls

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     5 METRICS PITFALLS                                  │
│                                                                         │
│  PITFALL 1: VANITY METRICS                                             │
│  ─────────────────────────                                            │
│  ❌ Mistake: Tracking metrics that look good but don't drive action  │
│  ✅ Fix: Focus on actionable metrics                                  │
│  Example: Total downloads vs. Monthly Active Users                   │
│                                                                         │
│  PITFALL 2: AVERAGES HIDE TRUTH                                       │
│  ───────────────────────────                                         │
│  ❌ Mistake: Only looking at averages                                │
│  ✅ Fix: Use cohort analysis to see patterns                         │
│  Example: Average retention is 20%, but with goals it's 40%         │
│                                                                         │
│  PITFALL 3: LAGGING INDICATORS ONLY                                  │
│  ───────────────────────────                                         │
│  ❌ Mistake: Only tracking metrics that tell you what happened       │
│  ✅ Fix: Also track leading indicators that predict what will happen │
│  Example: Retention (lagging) vs. Goal Setting Rate (leading)       │
│                                                                         │
│  PITFALL 4: NO BASELINE                                              │
│  ─────────────────────────────────                                    │
│  ❌ Mistake: Not tracking metrics before a feature launch           │
│  ✅ Fix: Always measure before and after                             │
│  Example: Retention was 15% before, 20% after (5% uplift)          │
│                                                                         │
│  PITFALL 5: MEASURING WITHOUT ACTION                                 │
│  ───────────────────────────                                         │
│  ❌ Mistake: Tracking metrics but not acting on them                │
│  ✅ Fix: Use metrics to drive decisions and experiments             │
│  Example: "Retention is low—let's run an experiment to fix it"    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Your Metrics Mantra

### The One Question That Guides Everything

When you're choosing metrics, when you're looking at a dashboard, when you're making a decision—come back to this:

> *"What metric would tell us we're succeeding, and what would we do if it moved?"*

### Why This Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     THE METRICS MANTRA                                  │
│                                                                         │
│  "WHAT METRIC WOULD TELL US WE'RE SUCCEEDING..."                     │
│  ───────────────────────────────────────────────────────────────       │
│  • Forces you to define success clearly                              │
│  • Prevents vanity metrics                                            │
│  • Aligns the team around the goal                                   │
│                                                                         │
│  "...AND WHAT WOULD WE DO IF IT MOVED?"                             │
│  ───────────────────────────────────────────────────────────────       │
│  • Ensures you're tracking actionable metrics                       │
│  • Prevents "measure and ignore" behavior                           │
│  • Drives decision-making and iteration                              │
│                                                                         │
│  Use this mantra when:                                                │
│  • Choosing what metrics to track                                   │
│  • Looking at your dashboard                                         │
│  • Making a product decision                                        │
│  • Planning experiments                                              │
└─────────────────────────────────────────────────────────────────────────┘
```

### Applying the Mantra

| Scenario | Mantra Says... |
|----------|----------------|
| "Should we track page views?" | "What would we do if page views moved? Nothing? Then don't track it." |
| "Retention is down 5%." | "What will we do about it? Run an experiment? Good—let's go." |
| "What's our North Star?" | "What metric tells us we're succeeding? WAU with Goal." |
| "Should we launch this feature?" | "What metric will tell us if it worked? Goal adoption? Great." |

---

## Primer Summary: What You Now Know

### Your 15-Minute Metrics Education

✅ You understand why metrics matter  
✅ You know the metrics hierarchy (North Star → KPIs → Health)  
✅ You have the AARRR framework (Acquisition → Activation → Retention → Referral → Revenue)  
✅ You can choose the right metrics (Metric Selection Framework)  
✅ You know how to build a metrics dashboard  
✅ You know the 5 metrics pitfalls to avoid  
✅ You have a mantra that guides everything  

### Your Metrics Mantra

> *"What metric would tell us we're succeeding, and what would we do if it moved?"*

### What's Next

This primer gives you the metrics mindset. Now you're ready to:

1. **Define** your North Star metric
2. **Build** your metrics dashboard
3. **Track** and analyze your metrics
4. **Act** on what you learn

---

## Quick Reference: One-Page Metrics Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ONE-PAGE METRICS SUMMARY                            │
│                                                                         │
│  METRICS = WHAT GETS MEASURED GETS MANAGED                             │
│  ─────────────────────────────────────                                 │
│  Data-driven > Opinion-driven                                          │
│                                                                         │
│  METRICS HIERARCHY:                                                   │
│  ─────────────────                                                    │
│  1. North Star Metric (Core value)                                    │
│  2. KPIs (Drivers of North Star)                                      │
│  3. Health Metrics (Product health)                                   │
│                                                                         │
│  AARRR FRAMEWORK:                                                     │
│  ──────────────                                                      │
│  Acquisition → Activation → Retention → Referral → Revenue           │
│                                                                         │
│  KEY METRICS:                                                         │
│  ────────────                                                         │
│  • NPS: Promoters% - Detractors%                                     │
│  • Retention: % active after X days                                  │
│  • ARPU: Total revenue / Total users                                 │
│  • LTV: ARPU × Average lifetime                                      │
│  • CAC: Marketing spend / New users                                 │
│  • DAU/MAU: Daily Active / Monthly Active                           │
│                                                                         │
│  5 PITFALLS TO AVOID:                                                │
│  ────────────────────                                                │
│  1. Vanity Metrics                                                   │
│  2. Averages Hide Truth                                              │
│  3. Lagging Indicators Only                                          │
│  4. No Baseline                                                     │
│  5. Measuring Without Action                                         │
│                                                                         │
│  THE METRICS MANTRA:                                                  │
│  ──────────────────                                                  │
│  "What metric would tell us we're succeeding, and what would we      │
│  do if it moved?"                                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

*End of Primer 6*

---

## Quick Navigation

**If you're new to metrics:** Start with this primer.  
**If you're building a dashboard:** Use the dashboard template.  
**If you're analyzing data:** Use the AARRR framework.  
**If you're preparing for interviews:** This primer helps with metrics questions.  
