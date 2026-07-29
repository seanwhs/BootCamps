# [GENERATED: Comprehensive Course Slide Deck]
# [STARTING: Student Workbook - Executive Decision Pipeline]

# Executive Decision Pipeline: Student Workbook

## Complete Hands-On Guide

---

## Workbook Introduction

### Welcome!
This workbook is your companion to the Executive Decision Pipeline course. It contains all the exercises, code examples, verification steps, and reflection questions you'll need to master the material.

### How to Use This Workbook
- **Follow along:** Complete exercises as you progress through the course
- **Write code:** Don't just read - type the code yourself
- **Take notes:** Use the reflection sections to capture your learnings
- **Track progress:** Check off completed exercises
- **Review:** Use for exam preparation and future reference

### Workbook Structure
Each module contains:
1. **Learning Objectives** - What you'll achieve
2. **Key Concepts** - Important terms and ideas
3. **Code Exercises** - Hands-on coding practice
4. **Verification Steps** - Confirm your work
5. **Reflection Questions** - Deepen understanding
6. **Challenge Exercises** - Stretch your skills

---

## Module 6.1: BI Semantic Layers Workbook

### Section 1.1: Database Setup Exercises

#### Exercise 1.1.1: Project Initialization

**Instructions:** Create the project directory structure and initial configuration files.

**Your Code:**
```bash
# Write your commands here:






```

**Verification:**
```bash
# Run these commands to verify:
ls -la ~/projects/executive-decision-pipeline
# Expected: Shows complete directory structure

tree -L 2
# Expected: Shows organized project tree
```

**Checklist:**
- [ ] Created project directory
- [ ] Created all subdirectories
- [ ] Created .env.example
- [ ] Created docker-compose.yml
- [ ] Created requirements.txt
- [ ] Created Makefile
- [ ] Initialized Git repository

---

#### Exercise 1.1.2: Docker Compose Setup

**Instructions:** Write the docker-compose.yml configuration for PostgreSQL and Metabase.

**Your Code:**
```yaml
# Complete the docker-compose.yml file:

version: '3.8'

services:
  postgres:
    image: 
    container_name: 
    environment:
      POSTGRES_DB: 
      POSTGRES_USER: 
      POSTGRES_PASSWORD: 
    ports:
      - 
    volumes:
      - 
    networks:
      - 

  metabase:
    image: 
    container_name: 
    ports:
      - 
    environment:
      MB_DB_TYPE: 
      MB_DB_DBNAME: 
      MB_DB_PORT: 
      MB_DB_USER: 
      MB_DB_PASS: 
      MB_DB_HOST: 
    depends_on:
      - 
    networks:
      - 

volumes:
  postgres_data:

networks:
  edp_network:
    driver: bridge
```

**Verification:**
```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# Expected: Both services running (Up)
```

**Reflection Questions:**
1. Why do we use Docker instead of installing PostgreSQL directly?


2. What are the benefits of using Docker Compose?


---

#### Exercise 1.1.3: Database Schema Design

**Instructions:** Write the complete schema for the customers table.

**Your Code:**
```sql
-- Write the CREATE TABLE statement for customers:










```

**Verification:**
```sql
-- Apply the schema
docker-compose exec -T postgres psql -U analytics_user -d analytics < scripts/create_schema.sql

-- Verify table creation
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics.*"
-- Expected: Shows all 10 tables
```

**Reflection Questions:**
1. What is the difference between dimension tables and fact tables?


2. Why do we use UUID as the primary key instead of SERIAL?


---

#### Exercise 1.1.4: Data Generation Script

**Instructions:** Complete the data generation script for customers.

**Your Code:**
```python
# Add the missing parts to generate sample customers:

def generate_customers(n):
    """Generate n realistic customers."""
    customers = []
    for _ in range(n):
        use_email = random.random() < 0.8
        email_domain = fake.free_email_domain()
        first_name = fake.first_name()
        last_name = fake.last_name()
        
        if use_email:
            email = 
        else:
            email = 
        
        has_phone = random.random() < 0.7
        has_birth_date = random.random() < 0.6
        
        customer = {
            'customer_id': ,
            'email': ,
            'first_name': ,
            'last_name': ,
            'phone':  if has_phone else None,
            'date_of_birth':  if has_birth_date else None,
            'registration_date': ,
            'last_login_date': None,
            'is_active': ,
            'is_verified': 
        }
        customers.append(customer)
    
    return pd.DataFrame(customers)
```

**Verification:**
```bash
# Run the data generation
python scripts/generate_sample_data.py

# Check row counts
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    'customers' as table_name, COUNT(*) as count FROM analytics.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM analytics.orders
UNION ALL
SELECT 'products', COUNT(*) FROM analytics.products;"
# Expected: 5,000 customers, 15,000 orders, 200 products
```

---

### Section 1.2: dbt Exercises

#### Exercise 1.2.1: dbt Installation and Configuration

**Instructions:** Install dbt and configure the profile.

**Your Code:**
```bash
# Write the installation commands:





# Write the profile configuration (profiles.yml):




```

**Verification:**
```bash
# Test dbt connection
dbt debug --project-dir .
# Expected: All checks passed!
```

**Reflection Questions:**
1. Why do we use dbt instead of writing raw SQL?


2. What is the purpose of the dbt profile?


---

#### Exercise 1.2.2: Staging Model Creation

**Instructions:** Complete the staging model for customers.

**Your Code:**
```sql
-- Complete the stg_customers.sql model:

{{
    config(
        materialized=,
        tags=
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'customers') }}
),

renamed AS (
    SELECT
        -- Primary key
        
        -- Personal information
        
        -- Calculate age from date of birth
        CASE 
            WHEN date_of_birth IS NOT NULL 
            THEN 
            ELSE NULL
        END AS age,
        
        -- Account information
        
        -- Status flags
        
        -- Derived: days since registration
        
        -- Derived: customer lifecycle stage
        
        -- Metadata
        
    FROM source
)

SELECT * FROM renamed
```

**Verification:**
```bash
# Run the staging model
dbt run --project-dir . --models staging

# Check the staging schema
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics_dbt.*"
# Expected: stg_customers view exists
```

---

#### Exercise 1.2.3: Intermediate Model Creation

**Instructions:** Complete the intermediate model for customer orders summary.

**Your Code:**
```sql
-- Complete the int_customer_orders_summary.sql model:

{{
    config(
        materialized=,
        tags=
    )
}}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS ,
        SUM(total_amount) AS ,
        AVG(total_amount) AS ,
        MIN(order_date) AS ,
        MAX(order_date) AS ,
        MAX(order_date) - MIN(order_date) AS 
    FROM orders
    GROUP BY customer_id
),

final AS (
    SELECT
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        c.registration_date,
        c.age,
        c.is_active,
        c.lifecycle_stage,
        
        -- Order summary
        COALESCE(co.total_orders, 0) AS ,
        COALESCE(co.total_spent, 0) AS ,
        COALESCE(co.avg_order_value, 0) AS ,
        
        -- Customer value tier
        
        -- Churn risk indicators
        
        -- Customer lifetime value
        
    FROM customers c
    LEFT JOIN customer_orders co ON c.customer_id = co.customer_id
)

SELECT * FROM final
```

**Verification:**
```bash
# Run intermediate models
dbt run --project-dir . --models intermediate

# Check the intermediate table
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT customer_tier, COUNT(*) FROM analytics_dbt.int_customer_orders_summary
GROUP BY customer_tier;"
# Expected: Shows customer tier distribution
```

---

#### Exercise 1.2.4: Mart Model Creation

**Instructions:** Complete the customer mart model.

**Your Code:**
```sql
-- Complete the dm_customer_360.sql mart model:

{{
    config(
        materialized=,
        schema=,
        tags=
    )
}}

WITH customer_summary AS (
    SELECT * FROM {{ ref('int_customer_orders_summary') }}
),

final AS (
    SELECT
        -- Customer identification
        
        -- Registration info
        
        -- Purchase behavior
        
        -- Customer value metrics
        
        -- Customer health score
        
    FROM customer_summary
)

SELECT * FROM final
```

**Verification:**
```bash
# Run mart models
dbt run --project-dir . --models marts

# Check mart tables
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics_dbt.marts"
# Expected: dm_customer_360 table exists
```

---

### Section 1.3: Dashboard Exercises

#### Exercise 1.3.1: Metabase Setup

**Instructions:** Configure Metabase and connect to PostgreSQL.

**Steps to Complete:**
1. Open http://localhost:3000 in your browser
2. Create admin account:
   - First name: _________
   - Last name: _________
   - Email: _________
   - Password: _________
3. Add database connection:
   - Database name: _________
   - Host: _________
   - Port: _________
   - Database name: _________
   - Username: _________
   - Password: _________
4. Wait for sync to complete

**Verification:**
```bash
# Check Metabase health
curl -s http://localhost:3000/api/health | python -m json.tool
# Expected: {"status": "ok"}

# Check database tables
curl -s http://localhost:3000/api/table | python -m json.tool
# Expected: Shows our mart tables
```

---

#### Exercise 1.3.2: Dashboard Question Creation

**Instructions:** Write the SQL for the following dashboard questions.

**Question 1: Monthly Revenue Trend**
```sql
-- Write SQL for monthly revenue trend:








```

**Question 2: Top Products by Revenue**
```sql
-- Write SQL for top products:








```

**Question 3: Customer Health Distribution**
```sql
-- Write SQL for customer health distribution:








```

**Verification:**
```bash
# Test your queries
docker-compose exec postgres psql -U analytics_user -d analytics -c "
-- Paste your query here
"
# Expected: Returns results with your data
```

---

#### Exercise 1.3.3: Dashboard Layout Design

**Instructions:** Design your dashboard layout. Sketch where each component will go.

```
┌─────────────────────────────────────────────────────────────────────┐
│ KPI ROW (6 cards)                                                 │
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐    │
│ │       │ │       │ │       │ │       │ │       │ │       │    │
│ └───────┘ └───────┘ └───────┘ └───────┘ └───────┘ └───────┘    │
├─────────────────────────────────────────────────────────────────────┤
│ TREND ROW (2 charts, double height)                               │
│ ┌────────────────────────────┐ ┌────────────────────────────┐    │
│ │                            │ │                            │    │
│ │                            │ │                            │    │
│ └────────────────────────────┘ └────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────────┤
│ DETAIL ROW (4 charts, single height)                              │
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐                        │
│ │       │ │       │ │       │ │       │                        │
│ └───────┘ └───────┘ └───────┘ └───────┘                        │
├─────────────────────────────────────────────────────────────────────┤
│ BOTTOM ROW (Campaign Performance, full width)                     │
│ ┌──────────────────────────────────────────────────────────────┐  │
│ │                                                              │  │
│ └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**Fill in the component types:**

1. KPI 1: _________________
2. KPI 2: _________________
3. KPI 3: _________________
4. KPI 4: _________________
5. KPI 5: _________________
6. KPI 6: _________________
7. Trend 1: _________________
8. Trend 2: _________________
9. Detail 1: _________________
10. Detail 2: _________________
11. Detail 3: _________________
12. Detail 4: _________________
13. Bottom: _________________

---

## Module 6.2: Analytics Storytelling Workbook

### Section 2.1: Executive Communication Exercises

#### Exercise 2.1.1: Executive Persona Identification

**Instructions:** Match the executive persona to the communication style.

| Persona | Focus | Pain Point | Communication Style |
|---------|-------|------------|---------------------|
| Visionary CEO | _______ | _______ | _______ |
| Operational CFO | _______ | _______ | _______ |
| Customer-Focused CMO | _______ | _______ | _______ |
| Technical CTO | _______ | _______ | _______ |

**Options:**
- A. Long-term growth, market leadership
- B. Cost efficiency, profitability
- C. Customer acquisition, retention
- D. Technical excellence, scalability
- E. Too many details, not enough context
- F. Vague recommendations, no ROI
- G. Not connecting to business outcomes
- H. Not understanding business context
- I. Lead with strategic impact
- J. Lead with financial metrics
- K. Highlight customer impact
- L. Connect technical to business

**Answers:**
1. Visionary CEO: ___, ___, ___
2. Operational CFO: ___, ___, ___
3. Customer-Focused CMO: ___, ___, ___
4. Technical CTO: ___, ___, ___

---

#### Exercise 2.1.2: SCR Framework Practice

**Instructions:** Fill in the SCR framework for a business scenario.

**Scenario:** Customer churn is increasing, and you need to recommend a solution.

**Situation (Where We Are Now):**
```
Current metrics:
- Customers: _________
- Monthly churn: _________
- Revenue: _________
- Industry churn: _________
```
**Your Situation Statement:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**Complication (What's the Problem):**
```
Key drivers of churn:
1. _________
2. _________
3. _________

Financial impact: $_________
```
**Your Complication Statement:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**Resolution (What Should We Do):**
```
Recommendations:
1. _________
2. _________
3. _________

Expected impact: _________
ROI: _________
Timeline: _________
```
**Your Resolution Statement:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

#### Exercise 2.1.3: Statistical Translation

**Instructions:** Translate the following statistical statements into business language.

**Statement 1:**
"p-value = 0.03 for the relationship between engagement and churn"

**Business Translation:**
```
_________________________________________________________________
_________________________________________________________________
```

**Statement 2:**
"R-squared = 0.85 for our revenue prediction model"

**Business Translation:**
```
_________________________________________________________________
_________________________________________________________________
```

**Statement 3:**
"95% confidence interval for average order value is [$82.50, $88.30]"

**Business Translation:**
```
_________________________________________________________________
_________________________________________________________________
```

**Statement 4:**
"ROC AUC = 0.92 for the churn prediction model"

**Business Translation:**
```
_________________________________________________________________
_________________________________________________________________
```

**Statement 5:**
"The effect size is d = 0.5 for the A/B test results"

**Business Translation:**
```
_________________________________________________________________
_________________________________________________________________
```

---

#### Exercise 2.1.4: Executive Summary Writing

**Instructions:** Write an executive summary for the churn reduction initiative.

**Executive Summary:**
```markdown
# Executive Summary
## Customer Retention Initiative

### Date: _______________
### Author: _______________
### Status: _______________

---

## 1. The Situation (Where We Are)

[Write 2-3 sentences about current state]


## 2. The Complication (What's Changed)

[Describe the problem and its impact]


## 3. The Resolution (What We Recommend)

[Clear recommendations with expected impact]


## 4. Implementation (How We'll Do It)

[Timeline, resources, milestones]


## 5. Decision Required (What We Need)

[Specific approval needed]


---

**Prepared by:** _______________
**Contact:** _______________
```

---

### Section 2.2: Presentation Exercises

#### Exercise 2.2.1: Presentation Storyboard

**Instructions:** Create a storyboard for your executive presentation.

**Slide 1: Title**
```
Content:
- Title: _________
- Subtitle: _________
- Presenter: _________
- Date: _________
```

**Slide 2: Agenda**
```
Content:
1. _________
2. _________
3. _________
4. _________
5. _________
```

**Slide 3: Situation**
```
Key Message: _________
Visual: _________
Data: _________
```

**Slide 4: Complication**
```
Key Message: _________
Visual: _________
Data: _________
```

**Slide 5: Resolution**
```
Key Message: _________
Visual: _________
Data: _________
```

**Slide 6: Implementation**
```
Key Message: _________
Visual: _________
Data: _________
```

**Slide 7: Decision**
```
Key Message: _________
Visual: _________
Data: _________
```

**Slide 8: Q&A**
```
Content:
- Questions
- Contact information
- Next steps
```

---

#### Exercise 2.2.2: Elevator Pitch Creation

**Instructions:** Write a 30-second elevator pitch for your retention initiative.

**Template:**
```
Situation: [Current state - 1 sentence]
Complication: [Problem - 1 sentence]
Resolution: [Solution - 2 sentences]
Impact: [Expected outcome - 1 sentence]
Ask: [What you need - 1 sentence]
```

**Your Elevator Pitch:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Module 6.3: Data Ethics Workbook

### Section 3.1: Fairness Exercises

#### Exercise 3.1.1: Fairness Metrics Calculation

**Instructions:** Calculate the fairness metrics for the given data.

**Data:**
| Group | Size | Selection Rate | Accuracy |
|-------|------|----------------|----------|
| A | 1000 | 0.22 | 0.86 |
| B | 500 | 0.18 | 0.82 |
| C | 250 | 0.26 | 0.84 |

**Calculations:**
1. Demographic Parity Difference:
   Max selection rate: _________
   Min selection rate: _________
   Difference: _________

2. Acceptance Threshold: Is DP < 0.10?
   [ ] Yes [ ] No

3. Disparate Impact:
   Highest selection rate: _________
   Lowest selection rate: _________
   Ratio: _________

4. Is DI > 0.80?
   [ ] Yes [ ] No

5. Which group has the highest accuracy?
   Group: _________
   Accuracy: _________

6. Which group has the lowest accuracy?
   Group: _________
   Accuracy: _________

**Reflection:**
Is this model fair based on these metrics? Explain.
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

#### Exercise 3.1.2: Bias Mitigation Strategies

**Instructions:** Match the mitigation strategy to the scenario.

| Scenario | Mitigation Strategy |
|----------|---------------------|
| Training data has fewer examples of minority groups | _________ |
| Model has different false positive rates across groups | _________ |
| Historical data contains societal biases | _________ |
| Model performs worse on one group overall | _________ |

**Options:**
A. Pre-processing: Reweighting
B. In-processing: Fairness constraints
C. Post-processing: Threshold adjustment
D. Pre-processing: Data collection

**Answers:**
1. ___
2. ___
3. ___
4. ___

---

#### Exercise 3.1.3: Fairness Analysis Implementation

**Instructions:** Complete the fairness analysis code.

**Your Code:**
```python
from fairlearn.metrics import (
    demographic_parity_difference,
    equalized_odds_difference
)

# Load your data and model
# _________

# Calculate predictions
y_pred = _________

# Define sensitive groups
groups = _________

# Calculate fairness metrics
dp_diff = demographic_parity_difference(
    y_true=_________,
    y_pred=_________,
    sensitive_features=_________
)

eo_diff = equalized_odds_difference(
    y_true=_________,
    y_pred=_________,
    sensitive_features=_________
)

# Print results
print(f"Demographic Parity Difference: {dp_diff:.3f}")
print(f"Equalized Odds Difference: {eo_diff:.3f}")

# Check thresholds
if dp_diff < 0.10:
    print("✅ Demographic parity satisfied")
else:
    print("⚠️ Demographic parity violation detected")

if eo_diff < 0.10:
    print("✅ Equalized odds satisfied")
else:
    print("⚠️ Equalized odds violation detected")
```

**Verification:**
```bash
# Run fairness analysis
python src/explainability/fairness_analysis.py

# Check output
# Expected: Fairness metrics with pass/fail status
```

---

### Section 3.2: Explainability Exercises

#### Exercise 3.2.1: SHAP Implementation

**Instructions:** Complete the SHAP explainability code.

**Your Code:**
```python
import shap
import pandas as pd
import numpy as np

# Load your model and data
model = _________
X_test = _________
feature_names = _________

# Create SHAP explainer
if model_type == 'xgboost':
    explainer = shap._________
elif model_type == 'linear':
    explainer = shap._________
else:
    explainer = shap._________

# Calculate SHAP values
shap_values = explainer.shap_values(_________)

# Generate summary plot
shap.summary_plot(
    shap_values=_________,
    features=_________,
    feature_names=_________
)

# Generate waterfall plot for first prediction
shap.waterfall_plot(
    shap.Explanation(
        values=_________,
        base_values=_________,
        data=_________,
        feature_names=_________
    )
)

# Calculate feature importance
importance = np.____________(shap_values, axis=0)

# Rank features
ranked_features = sorted(
    zip(_________, _________),
    key=lambda x: x[1],
    reverse=True
)

print("Top 5 Most Important Features:")
for feature, imp in ranked_features[:5]:
    print(f"  {feature}: {imp:.3f}")
```

**Verification:**
```bash
# Run SHAP explainability
python src/explainability/shap_explainer.py

# Check output
# Expected: SHAP visualizations and importance scores
```

---

#### Exercise 3.2.2: SHAP Analysis Interpretation

**Instructions:** Interpret the following SHAP analysis results.

**Feature Importance Data:**
| Feature | Mean |SHAP| | Direction |
|---------|----------|-----------|
| Customer Health Score | 0.45 | Negative |
| Days Since Last Purchase | 0.32 | Positive |
| Total Orders | 0.18 | Negative |
| Support Cases | 0.12 | Positive |
| Engagement Rate | 0.08 | Negative |

**Questions:**

1. Which feature is most important for predicting churn?
```
Answer: _________
```

2. What does a positive direction mean for Days Since Last Purchase?
```
Answer: _________
```

3. How would you describe the relationship between Customer Health Score and churn risk?
```
Answer: _________
```

4. Which feature has the least impact on predictions?
```
Answer: _________
```

5. What business insights can you derive from this analysis?
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### Section 3.3: Privacy Exercises

#### Exercise 3.3.1: Privacy-Preserving Techniques

**Instructions:** Identify the privacy technique for each scenario.

| Scenario | Technique |
|----------|-----------|
| Replacing names with random IDs | _________ |
| Adding noise to query results | _________ |
| Removing all identifying information | _________ |
| Hiding parts of SSN (XXX-XX-1234) | _________ |
| Replacing with random tokens | _________ |

**Options:**
A. Anonymization
B. Pseudonymization
C. Masking
D. Differential Privacy
E. Tokenization

**Answers:**
1. ___
2. ___
3. ___
4. ___
5. ___

---

#### Exercise 3.3.2: Anonymization Implementation

**Instructions:** Complete the privacy-preserving code.

**Your Code:**
```python
import hashlib
import secrets
import pandas as pd

class PrivacyTransformer:
    def __init__(self, salt=None):
        self.salt = salt or secrets.token_hex(16)
    
    def anonymize_column(self, df, column):
        """Anonymize a column using SHA-256 hashing."""
        def hash_value(value):
            return hashlib.sha256(
                (str(value) + self.salt).encode()
            ).hexdigest()[:16]
        
        df[column] = df[column].apply(_________)
        return df
    
    def pseudonymize(self, df, mapping):
        """Pseudonymize data using a mapping."""
        df_pseudo = df.copy()
        for original_col, new_col in mapping.items():
            unique_values = df_pseudo[original_col].unique()
            pseudonyms = {
                v: f"P_{i+1:04d}" for i, v in enumerate(_________)
            }
            df_pseudo[new_col] = df_pseudo[original_col].map(_________)
        return df_pseudo

# Example usage
data = pd.DataFrame({
    'customer_id': [1, 2, 3],
    'email': ['alice@example.com', 'bob@example.com', 'charlie@example.com']
})

transformer = PrivacyTransformer()
df_anon = transformer.anonymize_column(data, 'customer_id')
print(df_anon)
```

**Expected Output:**
```
   customer_id               email
0   a1b2c3d4e5f6g7h8  alice@example.com
1   i9j0k1l2m3n4o5p6    bob@example.com
2   q7r8s9t0u1v2w3x4  charlie@example.com
```

---

## Phase 6: Capstone Workbook

### Exercise: Executive Decision Pack Generation

#### Instructions:
Generate your complete Executive Decision Pack using the capstone script.

**Steps:**
1. Ensure all data is loaded and models are trained
2. Run the capstone generator
3. Review all outputs
4. Customize for your audience
5. Prepare for delivery

**Your Code:**
```bash
# Run the capstone generator

python capstone/scripts/generate_capstone.py

# Check the output
ls -la capstone/reports/
ls -la capstone/presentations/
```

**Output Checklist:**
- [ ] KPI Dashboard Visualization: capstone/reports/figures/kpi_dashboard.png
- [ ] Trend Visualizations: capstone/reports/figures/trend_visualizations.png
- [ ] Executive Summary: capstone/reports/executive_summary.md
- [ ] Explainability Report: capstone/reports/explainability/explainability_report.md
- [ ] Fairness Audit: capstone/reports/fairness/fairness_audit.md
- [ ] Implementation Roadmap: capstone/reports/implementation_roadmap.md
- [ ] Executive Presentation: capstone/presentations/executive_presentation.md

### Capstone Self-Evaluation

**Instructions:** Reflect on your completed Executive Decision Pack.

1. What was the most challenging part of the capstone?
```
_________________________________________________________________
_________________________________________________________________
```

2. What was the most rewarding part?
```
_________________________________________________________________
_________________________________________________________________
```

3. How would you explain your Executive Decision Pack to a non-technical executive?
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

4. What would you do differently next time?
```
_________________________________________________________________
_________________________________________________________________
```

5. How will you use these skills in your job?
```
_________________________________________________________________
_________________________________________________________________
```

---

## Appendix: Useful Code Snippets

### PostgreSQL Connection
```python
from sqlalchemy import create_engine, text

engine = create_engine('postgresql://user:pass@localhost:5432/db')
with engine.connect() as conn:
    result = conn.execute(text("SELECT * FROM table"))
    rows = result.fetchall()
```

### dbt Model Pattern
```sql
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'table') }}
),

renamed AS (
    SELECT
        id_column AS primary_key,
        column1 AS column1_clean,
        column2 AS column2_clean,
        created_at
    FROM source
)

SELECT * FROM renamed
```

### SHAP Explanation Pattern
```python
import shap

explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)
shap.summary_plot(shap_values, X_test, feature_names=features)
```

### Fairness Analysis Pattern
```python
from fairlearn.metrics import demographic_parity_difference, equalized_odds_difference

dp_diff = demographic_parity_difference(y_true, y_pred, sensitive_features=groups)
eo_diff = equalized_odds_difference(y_true, y_pred, sensitive_features=groups)
```

---

## Course Evaluation

**Your Name:** _______________
**Date:** _______________

### Overall Course Rating
| Aspect | Poor | Fair | Good | Excellent |
|--------|------|------|------|-----------|
| Content Quality | [ ] | [ ] | [ ] | [ ] |
| Code Examples | [ ] | [ ] | [ ] | [ ] |
| Exercise Difficulty | [ ] | [ ] | [ ] | [ ] |
| Instructor Quality | [ ] | [ ] | [ ] | [ ] |
| Materials Quality | [ ] | [ ] | [ ] | [ ] |
| Overall Value | [ ] | [ ] | [ ] | [ ] |

### What I Liked Most
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

### What I Liked Least
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

### What I Would Change
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

### Key Learnings
```
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________
4. _________________________________________________________________
5. _________________________________________________________________
```

### How I'll Apply This
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## Completion Checklist

**Module 6.1: BI Semantic Layers**
- [ ] Database setup complete
- [ ] dbt models built
- [ ] Metabase dashboard created
- [ ] Automated reports configured

**Module 6.2: Analytics Storytelling**
- [ ] Executive personas identified
- [ ] SCR framework applied
- [ ] Executive summary written
- [ ] Presentation designed

**Module 6.3: Data Ethics & Governance**
- [ ] Fairness analysis completed
- [ ] SHAP explanations generated
- [ ] Privacy measures implemented
- [ ] Governance framework defined

**Phase 6 Capstone**
- [ ] All components generated
- [ ] Executive Decision Pack complete
- [ ] Presentation prepared
- [ ] Ready for delivery

---

**Congratulations! You've completed the Executive Decision Pipeline course!**

**Next Steps:**
1. Review all materials
2. Practice with your own data
3. Share your Executive Decision Pack with stakeholders
4. Continue learning and growing
5. Make data-driven decisions!

---

**[END OF STUDENT WORKBOOK]**

---

*This workbook is your guide to mastering the Executive Decision Pipeline. Keep it handy for reference and review!*
