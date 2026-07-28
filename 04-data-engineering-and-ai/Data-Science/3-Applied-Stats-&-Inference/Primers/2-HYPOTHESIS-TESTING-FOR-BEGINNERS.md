# PRIMER 2: HYPOTHESIS TESTING FOR BEGINNERS

Welcome to the second primer! Building on the foundations from Primer 1, this primer will help you understand **hypothesis testing** — the framework that statisticians use to make decisions under uncertainty. We'll avoid complex math and focus on intuition, using real-world analogies throughout.

---

## P2.1 The Big Question: Does This Really Work?

### The Fundamental Problem

Imagine you're a product manager at an e-commerce company. You've redesigned the checkout button from blue to green. You think it will increase sales by 10%. But how do you know if it actually works?

**You can't be 100% sure. But you can be confident.**

Hypothesis testing is the tool that helps you quantify that confidence.

### The Scientific Method

```
1. Make a claim → "Green buttons increase sales"
2. Design an experiment → Show green to half, blue to half
3. Collect data → Measure sales from both groups
4. Analyze results → Is the difference real or random?
5. Draw conclusions → Should we use the green button?
```

---

## P2.2 The Two Hypotheses: Innocent Until Proven Guilty

### The Courtroom Analogy

Think of hypothesis testing like a **court trial**:

| Court Trial | Hypothesis Testing |
|-------------|-------------------|
| **Defendant is innocent** | **Null Hypothesis (H₀)** — No effect exists |
| **Defendant is guilty** | **Alternative Hypothesis (H₁)** — An effect exists |
| **Evidence against defendant** | **Data from experiment** |
| **Beyond reasonable doubt** | **p-value < significance level (α)** |

### The Null Hypothesis (H₀)

**Definition:** The default assumption that there is **no effect, no difference, no relationship**.

**Examples:**
- "Green buttons don't increase sales"
- "The drug doesn't work"
- "There's no difference between groups"

**The Null Hypothesis is "guilty until proven innocent"** — we assume it's true unless the evidence is overwhelming.

### The Alternative Hypothesis (H₁)

**Definition:** What you're trying to prove — there **is** an effect, difference, or relationship.

**Examples:**
- "Green buttons increase sales"
- "The drug works"
- "There is a difference between groups"

### Always Test the Null

```
Start with: H₀ is true (no effect)

Collect evidence (data)

Is the evidence strong enough to reject H₀?
│
├── YES → Reject H₀ (find an effect)
│
└── NO → Fail to reject H₀ (no evidence of effect)
```

---

## P2.3 P-Values: The Probability of Seeing This If Nothing is True

### What is a P-Value?

The p-value answers one very specific question:

**"If the null hypothesis were true (no real effect), what is the probability of seeing results as extreme as the ones we observed?"**

- **Small p-value:** The data is unlikely under the null hypothesis → evidence against H₀
- **Large p-value:** The data is likely under the null hypothesis → no evidence against H₀

### The Coin Flip Example

**Scenario:** You flip a coin 10 times and get 10 heads in a row.

**Question:** Is the coin fair, or is it rigged?

- **H₀:** The coin is fair (p(heads) = 0.5)
- **H₁:** The coin is rigged (p(heads) ≠ 0.5)

**Probability under H₀:** P(10 heads in 10 flips) = 0.5¹⁰ = 0.00098 (less than 0.1%)

**p-value:** 0.00098 (very small!)

**Conclusion:** This is extremely unlikely with a fair coin. We reject H₀ and conclude the coin is rigged.

### Interpreting P-Values

| p-value | Meaning | Strength of Evidence |
|---------|---------|---------------------|
| **p < 0.001** | Extremely unlikely | Very strong evidence ★★★ |
| **0.001 < p < 0.01** | Very unlikely | Strong evidence ★★ |
| **0.01 < p < 0.05** | Unlikely | Moderate evidence ★ |
| **0.05 < p < 0.10** | Possibly | Weak/marginal evidence |
| **p > 0.10** | Plausible | No evidence |

### Common Misinterpretations

| Misinterpretation | Correct Interpretation |
|-------------------|----------------------|
| "p = 0.05 means the null is 5% likely" | "p = 0.05 means 5% chance of seeing this data if null is true" |
| "p < 0.05 means the effect is large" | "p < 0.05 means the effect is statistically significant, but could be tiny" |
| "p > 0.05 means no effect exists" | "p > 0.05 means we don't have enough evidence to reject the null" |

---

## P2.4 The Significance Level (α): Setting the Bar

### What is α?

The **significance level (α)** is the threshold we set for rejecting the null hypothesis.

**If p < α, we reject H₀. If p ≥ α, we fail to reject H₀.**

### Common Significance Levels

| α | Interpretation | Use Case |
|---|----------------|----------|
| **0.10** | 10% chance of false positive | Exploratory research |
| **0.05** | 5% chance of false positive | Standard (most common) |
| **0.01** | 1% chance of false positive | Stringent (medical trials) |
| **0.001** | 0.1% chance of false positive | Very stringent (physics) |

### Choosing α

**Setting α too high:** More likely to make a false positive (Type I error) — claiming an effect when there isn't one.

**Setting α too low:** More likely to miss a real effect (Type II error) — claiming no effect when there is one.

**The trade-off:** There's always a balance between catching real effects and avoiding false positives.

### The α vs. p-value Relationship

```
If p < α:
    ┌─────────────────────────────────┐
    │       REJECT THE NULL HYPOTHESIS │
    │       "There IS an effect"       │
    └─────────────────────────────────┘

If p ≥ α:
    ┌─────────────────────────────────┐
    │   FAIL TO REJECT THE NULL HYPOTHESIS │
    │       "Not enough evidence for an effect" │
    └─────────────────────────────────┘
```

---

## P2.5 Type I and Type II Errors: When Things Go Wrong

### The Four Possible Outcomes

| | H₀ is True | H₀ is False |
|---|------------|-------------|
| **Reject H₀** | **Type I Error** (False Positive) | **Correct Decision** (Power) |
| **Fail to Reject H₀** | **Correct Decision** | **Type II Error** (False Negative) |

### Type I Error (False Positive)

**Definition:** Rejecting H₀ when it's actually true — saying there's an effect when there isn't.

**Example:** You conclude green buttons increase sales when they actually don't.

**Probability:** α (the significance level)

**Consequence:** Wasting resources on something that doesn't work

**Analogy:** A fire alarm that goes off when there's no fire

### Type II Error (False Negative)

**Definition:** Failing to reject H₀ when it's actually false — saying there's no effect when there is.

**Example:** You conclude green buttons don't increase sales when they actually do.

**Probability:** β (beta)

**Consequence:** Missing a real opportunity

**Analogy:** A fire that doesn't set off the alarm

### Power (1 - β)

**Definition:** The probability of correctly rejecting H₀ when it's false — detecting a real effect.

**Formula:** Power = 1 - β

**Interpretation:**
- Power = 0.80 means "80% chance of catching a real effect"
- Standard target power = 0.80

### The Trade-Off

```
        Lower α → Fewer false positives
                  ↓
        But also → Lower power (more false negatives)


        Higher α → More false positives
                  ↓
        But also → Higher power (fewer false negatives)
```

---

## P2.6 Effect Size: How Big is the Difference?

### Why Effect Size Matters

**Statistical significance ≠ Practical significance**

A result can be statistically significant (p < 0.05) but practically meaningless.

### Examples

| Effect | p-value | Is it significant? | Is it important? |
|--------|---------|-------------------|------------------|
| +0.1% conversion | 0.001 | ✅ Yes | ❌ No (tiny effect) |
| +20% conversion | 0.08 | ❌ No | ✅ Yes (big effect, but too small sample) |

### Types of Effect Sizes

#### Cohen's d (For comparing means)

**Interpretation:**
- d = 0.2: Small effect
- d = 0.5: Medium effect
- d = 0.8: Large effect

**Example:** If treatment increases test scores by 0.5 standard deviations (d=0.5), that's a medium effect.

#### Correlation (r)

**Interpretation:**
- r = 0.1: Weak correlation
- r = 0.3: Moderate correlation
- r = 0.5: Strong correlation

**Example:** If height and weight have r=0.7, there's a strong positive relationship.

#### Odds Ratio (For binary outcomes)

**Interpretation:**
- OR = 1: No effect
- OR = 2: Twice the odds
- OR = 0.5: Half the odds

**Example:** If OR = 1.5, the treatment group has 50% higher odds of conversion.

---

## P2.7 One-Tailed vs. Two-Tailed Tests

### The Difference

**Two-tailed test:** We don't know which direction the effect will go. We test for any difference.

**One-tailed test:** We predict the direction of the effect. We test if it's greater OR less than a value.

### Visual Comparison

```
Two-tailed Test:
    ┌─────────────────┐
    │     ----------  │
    │    /         \  │
    │   /           \ │
    │  /             \│
    │ │               │
    └─┼───────┼───────┼─
      │       μ       │
    Reject         Reject
    H₀ if         H₀ if
    t < -1.96     t > 1.96


One-tailed Test (Greater):
    ┌─────────────────┐
    │     ----------  │
    │    /         \  │
    │   /           \ │
    │  /             \│
    │ │               │
    └─┼───────────────┼─
      │               │
    Not Reject     Reject H₀
    H₀             if t > 1.645
```

### When to Use Each

| Test | When to Use | Example |
|------|-------------|---------|
| **Two-tailed** | You have no prediction about direction | "Does the new button change conversion rate?" |
| **One-tailed (greater)** | You predict it will increase | "Does the new button INCREASE conversion rate?" |
| **One-tailed (less)** | You predict it will decrease | "Does the new button DECREASE bounce rate?" |

### Important Warning

**Always pre-register your test type before collecting data.** Switching from two-tailed to one-tailed after seeing the data is p-hacking (unethical).

---

## P2.8 The Hypothesis Testing Process: Step-by-Step

### The Five Steps

#### Step 1: State the Hypotheses

**Example:** Testing a new drug for blood pressure

- **H₀:** The drug has no effect (μ = 0)
- **H₁:** The drug lowers blood pressure (μ < 0)

#### Step 2: Choose α

- α = 0.05 (standard)

#### Step 3: Collect Data and Calculate Test Statistic

- 100 patients take the drug
- Average decrease = 5 mmHg
- Standard deviation = 10 mmHg

#### Step 4: Calculate P-value

- t = (5 - 0) / (10 / √100) = 5
- p-value = 0.0000003

#### Step 5: Make a Decision

- p = 0.0000003 < 0.05
- **Reject H₀**
- **Conclusion:** The drug significantly lowers blood pressure

### The Visual Process

```
┌─────────────────────────────────────────────────────────┐
│                   1. State Hypotheses                    │
│   H₀: No effect     H₁: Effect exists                   │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   2. Choose α                            │
│   α = 0.05 (95% confidence)                             │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   3. Collect Data                       │
│   Run experiment, gather results                       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   4. Calculate p-value                   │
│   How likely is this data if H₀ is true?               │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   5. Make Decision                      │
│   p < α → Reject H₀ (statistically significant)        │
│   p ≥ α → Fail to reject H₀ (not significant)          │
└─────────────────────────────────────────────────────────┘
```

---

## P2.9 Common Mistakes and How to Avoid Them

### Mistake 1: P-Hacking

**Definition:** Running multiple tests or making decisions based on data to get a "significant" p-value.

**Examples:**
- Trying different tests until one gives p < 0.05
- Adding/removing variables until results are "significant"
- Stopping data collection early when results look good

**Solution:** Pre-register your analysis plan. Stick to it.

### Mistake 2: Misinterpreting Non-Significance

**Problem:** "p > 0.05 means no effect"

**Truth:** "p > 0.05 means we don't have enough evidence to detect an effect"

**Example:** Small sample size might miss a real effect.

### Mistake 3: Ignoring Practical Significance

**Problem:** "p < 0.05 means it matters"

**Truth:** A tiny effect can be statistically significant with a large sample.

**Example:** A drug that reduces blood pressure by 0.001 mmHg is statistically significant but practically meaningless.

### Mistake 4: Multiple Testing

**Problem:** Testing many hypotheses without correction increases false positives.

**Example:** Testing 100 different features — you'd expect 5 false positives by chance!

**Solution:** Use Bonferroni correction or FDR control.

### Mistake 5: Confusing Correlation with Causation

**Problem:** "A and B are correlated, so A causes B"

**Truth:** Correlation only shows association, not causation.

**Example:** Ice cream sales and crime are correlated, but neither causes the other.

---

## P2.10 Quick Reference: Hypothesis Testing in Plain English

| Term | Plain English Definition |
|------|-------------------------|
| **Null Hypothesis (H₀)** | "Nothing is happening" — the default assumption |
| **Alternative Hypothesis (H₁)** | "Something is happening" — what you're trying to prove |
| **p-value** | "If nothing is happening, how likely is this data?" |
| **Significance (α)** | "How much false positive risk are we willing to take?" |
| **Type I Error** | "False alarm" — saying there's an effect when there isn't |
| **Type II Error** | "Missed opportunity" — saying there's no effect when there is |
| **Power** | "Catching the effect" — probability of detecting a real effect |
| **Effect Size** | "How big is the effect?" — practical significance |

---

## P2.11 Quick Self-Check Quiz

### Question 1
What is the null hypothesis in a drug trial?

**Answer:** The drug has no effect (H₀: μ = 0)

### Question 2
If p = 0.03 and α = 0.05, what do you conclude?

**Answer:** p < α, so reject H₀ — there is statistically significant evidence of an effect

### Question 3
What's the difference between Type I and Type II errors?

**Answer:** Type I = false positive (saying there's an effect when there isn't); Type II = false negative (saying there's no effect when there is)

### Question 4
Why does effect size matter?

**Answer:** Statistical significance doesn't tell you how large or important the effect is.

### Question 5
What is p-hacking and why is it bad?

**Answer:** Manipulating the analysis to get p < 0.05. It's bad because it's unethical and leads to false conclusions.

---

## P2.12 Next Steps

With these foundations, you're ready to:

1. **Tackle Module 3.2:** Actual hypothesis testing with code
2. **Run your own A/B tests:** Apply these concepts to real data
3. **Avoid common pitfalls:** Make better decisions with statistics

### Key Takeaways

1. **Hypothesis testing** helps you make decisions under uncertainty
2. **The null hypothesis** is "no effect" — assume it's true until proven otherwise
3. **P-values** tell you how unlikely your data is if the null is true
4. **Small p-values** (p < α) lead to rejecting the null
5. **Significance** doesn't mean importance — check effect sizes
6. **Power** matters — don't run underpowered experiments
7. **Pre-register your analysis** to avoid p-hacking
8. **Correlation ≠ causation** — be careful with interpretation
x
