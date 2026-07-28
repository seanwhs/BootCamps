# PRIMER: STATISTICAL FOUNDATIONS FOR ABSOLUTE BEGINNERS

Welcome to the first primer! While the main tutorial assumes some familiarity with basic statistics, this primer is designed for **absolute beginners** — people who may have forgotten their high school math or are coming from a completely non-technical background. Think of this as your **statistical boot camp** — we'll build everything from the ground up using simple analogies and intuitive explanations.

---

## P1.1 What is Statistics, Really?

### The Core Problem: Uncertainty

Imagine you're a detective trying to solve a mystery. You can't interview every single person in the city, so you talk to a few witnesses (a **sample**) and try to figure out what happened to the whole population.

**Statistics is exactly like being a detective, but with numbers.**

You have three main jobs:

1. **Collect data** (gather evidence)
2. **Analyze data** (examine the evidence)
3. **Make decisions** (solve the case)

### The Two Types of Statistics

| Type | What It Does | Example |
|------|--------------|---------|
| **Descriptive Statistics** | Summarizes what you have | "The average height is 170 cm" |
| **Inferential Statistics** | Makes predictions about what you don't have | "We're 95% confident the average height is between 168-172 cm" |

### Real-World Analogy

**Descriptive Statistics** is like looking at a weather report for today: "It's 72°F and sunny." It tells you what's happening right now.

**Inferential Statistics** is like a weather forecast: "There's a 60% chance of rain tomorrow." It makes predictions based on current data.

---

## P1.2 Variables: The Building Blocks

### What is a Variable?

A **variable** is simply something that can change or vary. It's the thing you're measuring.

| Variable | What It Measures | Example |
|----------|------------------|---------|
| **Height** | How tall someone is | 170 cm |
| **Age** | How old someone is | 25 years |
| **Temperature** | How hot or cold | 72°F |
| **Conversion** | Did they buy? | Yes/No |

### Types of Variables

#### Quantitative (Numerical) Variables
Variables that are **numbers you can do math with**.

```
├── Continuous (can be any number)
│   └── Example: Height (170.5 cm, 172.3 cm)
│
└── Discrete (only whole numbers)
    └── Example: Number of children (0, 1, 2, 3...)
```

#### Categorical (Qualitative) Variables
Variables that are **categories or labels**.

```
├── Nominal (no order)
│   └── Example: Eye color (Blue, Brown, Green)
│
└── Ordinal (has order)
    └── Example: Education level (High School, College, Graduate)
```

### Quick Check: Identify the Variable Type

| Variable | Type | Why? |
|----------|------|------|
| "Age in years" | Quantitative (Discrete) | It's a number, but only whole years |
| "Temperature in Celsius" | Quantitative (Continuous) | Can be 23.5°C |
| "Gender" | Categorical (Nominal) | It's a category with no order |
| "Satisfaction rating (1-5)" | Categorical (Ordinal) | Has order, but 4 isn't twice as good as 2 |

---

## P1.3 Populations and Samples: The Big Picture

### The Difference

**Population** = Everyone you're interested in studying
**Sample** = A small group you actually measure

### Real-World Example

**Scenario:** You want to know the average height of all adults in a city with 1 million people.

- **Population:** All 1 million adults
- **Sample:** You measure 100 random adults
- **Challenge:** You can't measure everyone, so you use the sample to estimate the population

### Why We Use Samples

```
Population (1,000,000 people)
    │
    │ We can't measure everyone
    │
    ▼
Sample (100 people)
    │
    │ We measure these
    │
    ▼
Statistic (Sample average = 170 cm)
    │
    │ We infer about the population
    │
    ▼
Parameter (Population average ≈ 170 cm)
```

**Key Terms:**
- **Statistic:** A number from a sample (e.g., sample average)
- **Parameter:** A number from a population (e.g., population average)

---

## P1.4 The Mean, Median, and Mode: Three Ways to Find the "Middle"

### The Mean (The Average)

**What it is:** Add up all the numbers, divide by how many there are.

**Formula:** 
$$\bar{x} = \frac{\text{sum of all values}}{\text{number of values}}$$

**Example:** Test scores: 70, 75, 80, 85, 90

$$\bar{x} = \frac{70 + 75 + 80 + 85 + 90}{5} = \frac{400}{5} = 80$$

**When to use:** When data is symmetric with no outliers

### The Median (The Middle Value)

**What it is:** Sort the numbers, find the middle one.

**Even number of values:** Average the two middle values

**Example:** Test scores: 70, 75, 80, 85, 90
- Sorted: 70, 75, 80, 85, 90
- Middle: 80

**Example with even numbers:** 70, 75, 80, 85, 90, 95
- Sorted: 70, 75, 80, 85, 90, 95
- Middle two: 80 and 85
- Median: (80 + 85) / 2 = 82.5

**When to use:** When data has outliers or is skewed

### The Mode (The Most Common)

**What it is:** The value that appears most frequently

**Example:** Test scores: 70, 75, 80, 80, 85, 90, 95
- Most common: 80 (appears twice)

**When to use:** For categorical data or identifying typical values

### Which One to Use?

```
Is your data symmetric with no outliers?
│
├── YES → Use the Mean
│
└── NO → Use the Median
│
Is your data categorical?
│
└── YES → Use the Mode
```

### Real-World Example: Income Data

Imagine a neighborhood with 10 households:

**Incomes:** $50,000, $52,000, $55,000, $58,000, $60,000, $62,000, $65,000, $70,000, $75,000, $1,000,000

- **Mean:** $154,700 (pulled up by the millionaire)
- **Median:** ($60,000 + $62,000) / 2 = $61,000 (better represents typical income)
- **Mode:** None (all unique)

**Lesson:** The mean can be misleading with outliers. The median is often better for incomes, house prices, and other skewed data.

---

## P1.5 Spread: How Much Do Things Vary?

### Range: The Simplest Spread

**What it is:** Maximum - Minimum

**Example:** Test scores: 70, 75, 80, 85, 90
- Range = 90 - 70 = 20

**Problem:** Only uses two values, ignores everything in between.

### Variance and Standard Deviation: Average Distance from the Mean

#### Step-by-Step Example

Test scores: 70, 75, 80, 85, 90
Mean = 80

**Step 1:** Find the differences from the mean

| Score | Difference from Mean |
|-------|---------------------|
| 70 | 70 - 80 = -10 |
| 75 | 75 - 80 = -5 |
| 80 | 80 - 80 = 0 |
| 85 | 85 - 80 = 5 |
| 90 | 90 - 80 = 10 |

**Step 2:** Square the differences (to make them positive)

| Score | Difference | Squared |
|-------|------------|---------|
| 70 | -10 | 100 |
| 75 | -5 | 25 |
| 80 | 0 | 0 |
| 85 | 5 | 25 |
| 90 | 10 | 100 |

**Step 3:** Average the squared differences (this is the variance)

Variance = (100 + 25 + 0 + 25 + 100) / 5 = 250 / 5 = 50

**Step 4:** Take the square root of variance (this is the standard deviation)

Standard Deviation = √50 = 7.07

### Interpretation

**Small standard deviation:** Values are close to the mean (data is consistent)

**Large standard deviation:** Values are far from the mean (data is spread out)

### The 68-95-99.7 Rule (for normal data)

```
      68% of data lies within ±1 standard deviation
      95% of data lies within ±2 standard deviations
      99.7% of data lies within ±3 standard deviations
```

**Visual:**

```
          -3σ    -2σ    -1σ    μ      +1σ    +2σ    +3σ
           |      |      |      |      |      |      |
           |      |      |      |      |      |      |
           |      |██████|██████|██████|██████|      |
           |      |██████|██████|██████|██████|      |
           |██████|██████|██████|██████|██████|██████|
           |██████|██████|██████|██████|██████|██████|
           |████████████████████████████████████████|
           |████████████████████████████████████████|
           
           68% of data under the middle curve
           95% of data under the middle + next curves
           99.7% of data under all curves
```

---

## P1.6 The Normal Distribution: The Bell Curve

### What is the Normal Distribution?

The normal distribution is a **bell-shaped curve** that appears everywhere in nature:

- Heights of people
- Measurement errors
- Test scores
- Blood pressure readings
- IQ scores

### Characteristics of a Normal Distribution

```
          μ (Mean)
           │
           ▼
         _____
        /     \      ← Symmetric
       /       \
      /         \
     /           \
    /             \
   /_______________\  ← Tails go to infinity
```

**Key Features:**
1. **Symmetric:** Left side mirrors right side
2. **Mean = Median = Mode:** All three are the same
3. **Bell-shaped:** Highest in the middle, gets lower toward the edges
4. **Tails:** Extend infinitely in both directions

### The Empirical Rule (68-95-99.7)

For any normal distribution:

- **68%** of data is within **±1 standard deviation** of the mean
- **95%** of data is within **±2 standard deviations** of the mean
- **99.7%** of data is within **±3 standard deviations** of the mean

### Example: IQ Scores

IQ scores follow a normal distribution with:
- Mean (μ) = 100
- Standard deviation (σ) = 15

```
68% of people: IQ between 85 and 115
95% of people: IQ between 70 and 130
99.7% of people: IQ between 55 and 145
```

---

## P1.7 Sampling: The Art of Selection

### Why Sampling Matters

You can't always measure everyone. Sampling lets you:

1. **Save time** (interview 100 people instead of 1 million)
2. **Save money** (costs less to measure fewer people)
3. **Be more accurate** (fewer measurement errors in a smaller group)

### Types of Samples

| Type | How It Works | Example |
|------|--------------|---------|
| **Simple Random** | Everyone has equal chance | Drawing names from a hat |
| **Stratified** | Divide into groups, sample from each | Sampling by age group |
| **Cluster** | Sample entire groups | Sampling schools, not individual students |
| **Systematic** | Select every nth person | Every 10th person on a list |

### Biased Sampling (What to Avoid)

**Selection Bias:** When some members of the population are more likely to be selected

**Example:** Surveying only people in a mall — you miss people who don't go to malls

**Volunteer Bias:** People who volunteer are different from people who don't

**Example:** Online polls — only people who feel strongly respond

### Random Sampling is Your Friend!

**Random sampling** (everyone has an equal chance of being selected) is the gold standard because it:
1. Eliminates selection bias
2. Allows you to use probability theory
3. Makes your results generalizable

---

## P1.8 Correlation vs. Causation: A Crucial Difference

### The Ice Cream and Crime Example

**Observation:** Ice cream sales and crime rates both increase in summer.

**Wrong conclusion:** Eating ice cream causes crime!

**Right conclusion:** Both are caused by a third factor (hot weather).

### The Difference

| Correlation | Causation |
|-------------|-----------|
| Two things happen together | One thing directly causes the other |
| "A is related to B" | "A causes B" |
| Example: Ice cream sales ↑, crime ↑ | Example: Smoking causes lung cancer |

### Three Conditions for Causation

1. **Correlation:** A and B are related
2. **Temporal Order:** A happens before B
3. **No Confounders:** No other explanation for the relationship

### Confounding Variables

A **confounder** is a variable that influences both the independent variable and the dependent variable.

```
        Confounder
             │
    ┌────────┴────────┐
    ▼                 ▼
  Ice Cream         Crime
  Sales              Rate
```

**Without controlling for confounders, you can't claim causation!**

---

## P1.9 Key Terms in Plain English

| Term | Plain English Definition |
|------|-------------------------|
| **Statistics** | Using numbers to make decisions under uncertainty |
| **Variable** | Something that can change (height, age, etc.) |
| **Population** | Everyone you're interested in |
| **Sample** | The people you actually measure |
| **Mean** | The average |
| **Median** | The middle value |
| **Mode** | The most common value |
| **Variance** | How spread out the data is |
| **Standard Deviation** | Average distance from the mean |
| **Normal Distribution** | The bell curve |
| **Correlation** | Two things happening together |
| **Causation** | One thing causing another |
| **Random Sample** | Everyone has equal chance of being selected |
| **Bias** | Systematic error in sampling or measurement |

---

## P1.10 Quick Self-Check Quiz

### Question 1
You're studying the average height of people in your city. You measure 500 people.

- **What is the population?** 
  - Answer: Everyone in the city
- **What is the sample?** 
  - Answer: The 500 people you measured

### Question 2
The salaries in a company are: $30,000, $35,000, $40,000, $45,000, $50,000, $500,000

- **What is the mean?** 
  - Answer: ($30,000+35,000+40,000+45,000+50,000+500,000)/6 = $116,667
- **What is the median?** 
  - Answer: ($40,000+$45,000)/2 = $42,500
- **Which is more representative?** 
  - Answer: The median ($42,500) — the mean is pulled up by the outlier

### Question 3
True or False: If two variables are correlated, one must cause the other.

- **Answer:** False! Correlation does not imply causation.

### Question 4
What type of variable is "number of children in a family"?

- **Answer:** Quantitative (Discrete) — it's a number, but only whole numbers

### Question 5
What type of variable is "favorite color"?

- **Answer:** Categorical (Nominal) — it's a category with no natural order

---

## P1.11 Next Steps

Now that you understand the foundations, you're ready for:

1. **The Main Series:** Module 3.1 will build on these concepts
2. **More Advanced Topics:** Distributions, hypothesis testing, regression
3. **Real-World Applications:** Apply these concepts to your own data

### Key Takeaways

1. **Statistics helps you make decisions with incomplete information**
2. **Samples represent populations**
3. **The mean is good for symmetric data; median is better for skewed data**
4. **Standard deviation measures spread**
5. **The normal distribution appears everywhere**
6. **Random sampling is key to getting good results**
7. **Correlation is NOT causation**
