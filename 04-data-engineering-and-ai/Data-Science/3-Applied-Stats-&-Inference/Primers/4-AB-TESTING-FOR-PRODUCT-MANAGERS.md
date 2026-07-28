# PRIMER 4: A/B TESTING FOR PRODUCT MANAGERS

Welcome to the final primer! This primer is designed specifically for **product managers, business leaders, and non-statisticians** who need to understand and make decisions based on A/B tests. We'll focus on practical understanding, actionable insights, and what actually matters for business decisions — with minimal math and maximum clarity.

---

## P4.1 What is A/B Testing?

### The Core Idea

**A/B testing is a scientific way to make product decisions.**

Instead of guessing whether a new feature will work, you:
1. Show the current version to half your users (Group A)
2. Show the new version to the other half (Group B)
3. Compare which group performs better
4. Make a data-driven decision

### Real-World Examples

| Product | What They Tested | Why It Matters |
|---------|------------------|----------------|
| **Google** | 41 shades of blue for links | Even tiny color changes affect clicks |
| **Netflix** | Different thumbnail images | Better thumbnails = more viewers |
| **Amazon** | "Buy Now" button placement | Easier checkout = more sales |
| **Airbnb** | Search ranking algorithms | Better matches = more bookings |

### The Golden Rule

**Randomization is the key.** Users should be randomly assigned to groups so that the only difference between groups is the change you're testing.

```
        All Users
            │
    ┌───────┴───────┐
    ▼               ▼
  Group A         Group B
  (Control)       (Treatment)
  50% of users    50% of users
    │               │
  Current         New
  Version         Version
    │               │
  Measure         Measure
  Outcome         Outcome
    │               │
    └───────┬───────┘
            ▼
        Compare
        Results
```

---

## P4.2 The Key Metrics: What to Measure

### Choosing the Right Metric

**Primary Metric:** The most important thing you're trying to improve

**Secondary Metrics:** Supporting metrics that help explain the results

**Guardrail Metrics:** Metrics that shouldn't get worse (like performance or reliability)

### Types of Metrics

#### Business Metrics
| Metric | What It Measures | Example |
|--------|------------------|---------|
| **Conversion Rate** | % of users who take desired action | Purchases, sign-ups |
| **Revenue** | Money generated | Average order value, total sales |
| **Retention** | Users who come back | 7-day active users |
| **LTV** | Lifetime value | Total revenue per customer |

#### Engagement Metrics
| Metric | What It Measures | Example |
|--------|------------------|---------|
| **Click-Through Rate** | % who click | Ad clicks, link clicks |
| **Time on Site** | How long users stay | Session duration |
| **Page Views** | How many pages they visit | Depth of engagement |
| **Return Rate** | How often they come back | Daily/weekly active users |

#### Experience Metrics
| Metric | What It Measures | Example |
|--------|------------------|---------|
| **Load Time** | How fast page loads | Time to first byte |
| **Error Rate** | How often things break | 404s, timeouts |
| **Satisfaction** | User happiness | NPS, ratings |

### The Golden Rule of Metrics

**Choose one primary metric and stick to it.**

Don't cherry-pick metrics after seeing the results. This is p-hacking (unethical and leads to false conclusions).

### Examples of Primary Metrics

| Business Goal | Primary Metric |
|---------------|----------------|
| Increase sales | Conversion rate or Revenue per user |
| Grow user base | Sign-up rate |
| Improve engagement | Time on site |
| Reduce churn | 7-day retention rate |

---

## P4.3 Sample Size: How Many Users Do You Need?

### The Sample Size Sweet Spot

Too small → You'll miss real effects
Too large → You're wasting time and resources
Just right → You'll detect the effect you care about

### What Affects Sample Size

| Factor | How It Affects Sample Size |
|--------|---------------------------|
| **Effect Size** | Smaller effects need more users |
| **Baseline Rate** | Higher baseline needs more users to detect small improvements |
| **Statistical Power** | Higher power needs more users |
| **Significance Level** | Lower α needs more users |
| **Variability** | More variability needs more users |

### Rules of Thumb

| Scenario | Sample Size (per group) |
|----------|------------------------|
| **Detecting 2% change in 10% conversion** | ~5,000 users |
| **Detecting 5% change in 10% conversion** | ~1,000 users |
| **Detecting 10% change in 10% conversion** | ~300 users |
| **Detecting 20% change in 50% conversion** | ~200 users |

### The Sample Size Calculator

**Quick formula for proportions:**

$$n \approx \frac{16 \times \text{baseline} \times (1 - \text{baseline})}{\text{effect size}^2}$$

**Example:** Baseline = 10%, effect = 2% (absolute)

$n \approx \frac{16 \times 0.10 \times 0.90}{0.02^2} = \frac{1.44}{0.0004} = 3,600$

### How Long Will It Take?

**Calculation:** Time = Sample Size / Daily Traffic

**Example:** Need 3,600 users per group, get 1,000 visits per day

Time = 3,600 / 1,000 = 3.6 days

**Check:** Is 2% effect worth waiting for?

### The 80% Power Rule

**Target:** 80% power (20% chance of missing a real effect)

**Analogy:** 80% power means "8 out of 10 times the effect is real, we'll detect it"

---

## P4.4 Running the Experiment

### Before the Test

1. **Define success:** What metric matters?
2. **Set the duration:** How long will the test run?
3. **Calculate sample size:** Do you have enough users?
4. **Check for conflicts:** Are other tests running simultaneously?
5. **Pre-register:** Write down your hypothesis and test plan

### During the Test

1. **Randomize properly:** Ensure users are truly random
2. **Stay consistent:** Don't change the test once it starts
3. **Monitor guardrails:** Check nothing is breaking
4. **Don't peek:** Resist checking results early (or adjust for multiple peeking)

### The Peeking Problem

**The issue:** Checking results repeatedly and stopping early when results look "good" inflates false positive rates.

**Example:** If you check 10 times, the false positive rate goes from 5% to 40%!

**Solution:** 
- Decide on a fixed duration
- Don't check until the end
- Or use sequential testing methods

### How Long to Run?

**Minimum duration:** 1-2 weeks (to account for daily patterns)

**Why weeks matter:**
- Users behave differently on weekends vs. weekdays
- Seasonal patterns affect behavior
- Need to capture the full user cycle

### When to Stop

**Stop the test when:**
- The planned duration is reached
- The required sample size is achieved
- OR the confidence interval is sufficiently narrow

**Don't stop when:**
- You like the results and want to roll out early
- The p-value just crossed below 0.05

---

## P4.5 Interpreting Results: What to Look For

### The Confidence Interval

**What it is:** A range that likely contains the true effect

**Example:** 95% CI = [2%, 4%]

**Interpretation:** We're 95% confident the true effect is between 2% and 4%.

### The P-Value

**What it is:** Probability of seeing these results if there was no effect

**Example:** p = 0.03

**Interpretation:** There's a 3% chance of seeing a 2% lift if the button actually had no effect

**Decision rule (α = 0.05):**
- p < 0.05 → statistically significant → likely a real effect
- p ≥ 0.05 → not statistically significant → insufficient evidence

### The Effect Size

**What it is:** How big the difference is

**Example:** +2% conversion rate

**Interpretation:** "The new button increased conversion by 2 percentage points (from 10% to 12%)"

### The Business Impact

**What it is:** What the effect means for your business

**Example:** 2% increase × 100,000 users × $10 per conversion = $20,000

### What to Look For

```
        Significance    |    Importance
                        |
     ↓                  |    ↓
     ┌──────────────────────────────┐
     │   Significant    │   Not     │
     │   and            │   Significant│
     │   Important      │           │
     │                  │           │
     │   ✓ Roll out!    │   ❌ Need │
     │                  │   More   │
     │                  │   Data   │
     │                  │           │
     │   ⚠ Possibly    │   ✓ Stop  │
     │   but think     │   Testing │
     │   about impact  │           │
     └──────────────────────────────┘
```

### The Four Outcomes

| Significant? | Effect Important? | Decision |
|--------------|-------------------|----------|
| ✅ Yes | ✅ Yes | **ROLL OUT** — The change works and matters |
| ✅ Yes | ❌ No | **REJECT** — Statistically significant but tiny effect |
| ❌ No | ✅ Yes | **NEED MORE DATA** — Too small sample size |
| ❌ No | ❌ No | **STOP** — No evidence of meaningful effect |

---

## P4.6 Common Pitfalls for Product Managers

### Pitfall 1: Ending Tests Early

**Problem:** You check results after 3 days, see p < 0.05, and stop the test.

**Why it's bad:** Early stopping increases false positive rates dramatically.

**Solution:** Fix the duration in advance. Stick to it.

### Pitfall 2: Testing Too Many Things at Once

**Problem:** You change 5 things in your treatment group.

**Problem:** If the test works, you don't know which change caused the improvement.

**Solution:** Test one change at a time. Or use A/B/n or multivariate testing.

### Pitfall 3: Ignoring Segments

**Problem:** You see no overall effect, but the change works great for mobile users and poorly for desktop users.

**Solution:** Always check segments (device, location, user type).

### Pitfall 4: Not Running the Test Long Enough

**Problem:** You stop the test after 2 days because you hit sample size.

**Problem:** Daily patterns (weekends, holidays) might change the results.

**Solution:** Always run for at least 1-2 weeks, regardless of sample size.

### Pitfall 5: Over-Optimizing

**Problem:** You test 50 variations of the button color to find the "winning" one.

**Problem:** You'll find a winner by chance alone! (Multiple testing)

**Solution:** Test a reasonable number of variants with corrections.

### Pitfall 6: Ignoring Practical Significance

**Problem:** You get p < 0.05, so you roll out the change.

**Problem:** The change increases conversion by 0.1% — meaningless for the business.

**Solution:** Always ask: "Does this effect matter for the business?"

---

## P4.7 Making Business Decisions

### The Decision Framework

```
                Effect Size
                ┌──────────────────────────────────────┐
                │  Tiny    │  Small   │  Medium  │ Large │
                │  (<0.5%) │ (1-2%)   │ (2-5%)   │ (>5%)  │
───┼────────────┼──────────┼──────────┼──────────┼────────┼
    │            │          │          │          │        │
    │  Cost is   │  ❌ No   │  ⚠ Maybe │  ✅ Yes  │  ✅ Yes│
    │  High      │          │          │          │        │
    │            │          │          │          │        │
    │  Cost is   │  ⚠ Maybe │  ✅ Yes  │  ✅ Yes  │  ✅ Yes│
    │  Low       │          │          │          │        │
    │            │          │          │          │        │
───┘            └──────────┴──────────┴──────────┴────────┘

Key: ✅ = Roll out, ⚠ = Consider carefully, ❌ = Don't roll out
```

### Cost vs. Benefit

| Factor | Consideration |
|--------|---------------|
| **Development Cost** | How much effort to implement? |
| **Risk** | Could the change break anything? |
| **Maintenance** | Will this be harder to maintain? |
| **Opportunity Cost** | What else could you be building? |

### The ROI Calculation

**ROI = (Benefit - Cost) / Cost**

**Example:**
- Cost to implement: $10,000
- Expected benefit: $50,000/year
- ROI = ($50,000 - $10,000) / $10,000 = 400%

**Decision:** 400% ROI is a great investment!

---

## P4.8 Communicating Results to Stakeholders

### The Pyramid Principle

Start with the most important insight first, then add details.

```
┌─────────────────────────────────────┐
│  "The new checkout button           │
│   increased conversion by 2%."      │  ← The Bottom Line
├─────────────────────────────────────┤
│                                     │
│  "We're 95% confident it's between  │
│   1.5% and 2.5%."                   │  ← The Evidence
│                                     │
│  "We tested 10,000 users for 2      │
│   weeks."                           │  ← The Details
├─────────────────────────────────────┤
│                                     │
│  "Recommendation: Roll out to       │
│   100% of users."                   │  ← The Action
│                                     │
│  "Next steps: Monitor metrics for   │
│   the next month."                  │  ← The Plan
└─────────────────────────────────────┘
```

### The Template

**Executive Summary (1-2 sentences)**
- "The new checkout button increased conversion by 2 percentage points (from 10% to 12%)."

**Details (3-5 sentences)**
- "We ran a 2-week A/B test with 10,000 users. The treatment group showed a statistically significant improvement (p=0.03, 95% CI [1.5%, 2.5%]). Mobile users saw the biggest improvement (3%)."

**Recommendation (1-2 sentences)**
- "We recommend rolling out the new button to all users on Monday, pending your approval."

**Next Steps**
- Monitor metrics for the next month
- Consider segment-specific tests

### Presenting to Non-Technical Audiences

| Instead of... | Say... |
|---------------|--------|
| "p = 0.03" | "There's only a 3% chance this result happened by chance" |
| "95% Confidence Interval" | "We're 95% sure the true increase is between 1.5% and 2.5%" |
| "Statistical significance" | "We're confident this isn't random fluctuation" |
| "Effect size" | "The actual impact was 2 percentage points" |

### Visualization

Always include a simple chart:

```
Conversion Rate
    │
15% │          ■
    │          ■
10% │    ■     ■
    │    ■     ■
 5% │    ■     ■
    │    ■     ■
 0% │    ■     ■
    └───────────────────
        Control  Treatment
```

---

## P4.9 Key Questions to Ask

### During Design Phase

1. "What problem are we trying to solve?"
2. "What's the primary metric?"
3. "How many users do we need?"
4. "How long will this take?"
5. "Are there any other tests running?"

### During Analysis Phase

1. "Is the effect statistically significant?"
2. "Is the effect practically significant?"
3. "What does the confidence interval say?"
4. "Are there any surprising segment differences?"
5. "What's the business impact?"

### During Decision Phase

1. "Is this change worth the cost?"
2. "What's the risk if we roll this out?"
3. "Do we need more data?"
4. "What's the alternative?"

---

## P4.10 Quick Reference: A/B Testing in Plain English

| Term | Plain English Definition |
|------|-------------------------|
| **A/B Test** | Comparing two versions to see which works better |
| **Control** | The current version |
| **Treatment** | The new version |
| **Conversion** | The user taking the desired action |
| **Sample Size** | How many users you need |
| **Statistical Significance** | "We're confident this isn't random" |
| **Practical Significance** | "This matters for the business" |
| **Confidence Interval** | "We're X% confident the true effect is between Y and Z" |
| **Power** | "The chance of catching a real effect" |
| **p-value** | "The chance this is just random noise" |

---

## P4.11 The Decision Matrix

### When to Stop a Test

| Scenario | Decision |
|----------|----------|
| **Positive effect, significant, important** | 🟢 Roll out |
| **Positive effect, significant, tiny** | 🟡 Maybe not worth it |
| **Positive effect, not significant** | 🔴 Need more data or not real |
| **Negative effect, significant** | 🔴 Don't roll out |
| **Negative effect, not significant** | 🟡 Probably no effect, but not sure |
| **No difference** | 🔴 Stop testing |

### When to Continue

| Scenario | Decision |
|----------|----------|
| **Effect going in the right direction, not yet significant** | Continue |
| **Small sample, large effect** | Continue to confirm |
| **Large sample, effect not significant** | Consider stopping |
| **Multiple metrics disagree** | Continue or investigate |

---

## P4.12 Quick Self-Check Quiz

### Question 1
You run an A/B test and get p = 0.06. Your α = 0.05. What do you conclude?

**Answer:** Not statistically significant. You don't have enough evidence to conclude there's an effect.

### Question 2
You get p = 0.02 with a 0.1% lift in conversion. Should you roll out the change?

**Answer:** Statistically significant but practically insignificant. Consider whether the tiny lift is worth the implementation cost and risk.

### Question 3
You test 50 variations of a button color and find one that's significant at p = 0.04. Should you trust it?

**Answer:** No! That's likely a false positive (multiple testing). You need corrections or a replication test.

### Question 4
Why shouldn't you check results every day and stop when you like what you see?

**Answer:** Peeking increases false positive rates and can lead to wrong conclusions.

### Question 5
What's more important: statistical significance or practical significance?

**Answer:** Both! Statistical significance means it's real; practical significance means it matters. You need both for a good decision.

---

## P4.13 Next Steps

With this primer, you're ready to:

1. **Run your first A/B test:** Apply these concepts
2. **Interpret results:** Make confident business decisions
3. **Lead teams:** Guide data-driven product decisions

### Key Takeaways

1. **A/B testing** helps you make data-driven decisions
2. **Randomization** is the key to valid results
3. **Choose one primary metric** and stick to it
4. **Calculate sample size** before you start
5. **Don't peek** at results early
6. **Check both statistical AND practical significance**
7. **Communicate clearly** to all stakeholders
8. **Focus on business impact**, not just statistical details

x
