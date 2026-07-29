# Executive Decision Pipeline: Quiz & Test Bank
## Complete Assessment Package with Answer Keys

---

## How to Use This Test Bank

This comprehensive test bank contains:
1. **Module Quizzes** - Short quizzes for each module (15-20 questions each)
2. **Module Exams** - Comprehensive exams for each module (30-40 questions each)
3. **Final Exam** - Complete course assessment (50 questions)
4. **Answer Keys** - Detailed explanations for all questions
5. **Coding Challenges** - Practical implementation exercises
6. **Case Studies** - Real-world scenario questions

### Question Types
- **Multiple Choice:** Select the best answer
- **True/False:** Determine if the statement is correct
- **Fill in the Blank:** Complete the missing information
- **Matching:** Connect related concepts
- **Short Answer:** Brief written response
- **Coding:** Write or complete code snippets
- **Case Study:** Apply concepts to scenarios

### Grading Guide
| Score | Grade | Interpretation |
|-------|-------|----------------|
| 90-100% | A | Excellent understanding |
| 80-89% | B | Good understanding |
| 70-79% | C | Adequate understanding |
| 60-69% | D | Needs review |
| <60% | F | Requires remediation |

---

## MODULE 6.1 QUIZ: BI Semantic Layers

### Multiple Choice (10 Questions)

**1. What is a semantic layer?**
- A) A physical storage layer for data
- B) A business-friendly abstraction of data that centralizes definitions
- C) A database optimization technique
- D) A data visualization tool

**2. Which dbt model type is best for cleaning raw data?**
- A) Mart model
- B) Intermediate model
- C) Staging model
- D) Source model

**3. What is the purpose of dbt?**
- A) To visualize data
- B) To version-control SQL transformations
- C) To store data
- D) To create machine learning models

**4. Which materialization type is best for mart models?**
- A) View
- B) Table
- C) Incremental
- D) Ephemeral

**5. What does the `{{ ref() }}` function do in dbt?**
- A) References a source table
- B) References another dbt model
- C) Creates a new table
- D) Drops a table

**6. Which JOIN type returns all rows from the left table and matching rows from the right?**
- A) INNER JOIN
- B) LEFT JOIN
- C) RIGHT JOIN
- D) FULL OUTER JOIN

**7. What is the purpose of the `DATE_TRUNC` function?**
- A) To delete dates
- B) To truncate dates to a specified precision
- C) To add days to a date
- D) To convert dates to strings

**8. Which Metabase feature allows automated email reports?**
- A) Dashboards
- B) Questions
- C) Pulses
- D) Collections

**9. What is normalization in database design?**
- A) Making data look nice
- B) Organizing data to reduce redundancy
- C) Creating indexes
- D) Compressing data

**10. Which of the following is NOT a type of dbt test?**
- A) Unique
- B) Not null
- C) Accepted values
- D) Visualization

---

### True/False (5 Questions)

**11.** dbt models can only be materialized as views.
- [ ] True
- [ ] False

**12.** A LEFT JOIN returns all rows from both tables.
- [ ] True
- [ ] False

**13.** Metabase is an open-source BI tool.
- [ ] True
- [ ] False

**14.** Staging models should be materialized as tables.
- [ ] True
- [ ] False

**15.** Primary keys ensure data integrity by preventing duplicate records.
- [ ] True
- [ ] False

---

### Fill in the Blank (5 Questions)

**16.** The dbt function that references a source table is {{ __________ }}.

**17.** The three layers of dbt models are staging, __________, and marts.

**18.** In a well-designed dashboard, __________ should come first.

**19.** The command to start Docker services is `docker-compose __________`.

**20.** The SQL function that handles NULL values is __________.

---

### Answer Key: Module 6.1 Quiz

**Multiple Choice:**
1. **B** - A business-friendly abstraction of data
   *Explanation: A semantic layer translates technical data into business concepts and centralizes definitions.*

2. **C** - Staging model
   *Explanation: Staging models clean and prepare raw data. They are the first layer of transformation.*

3. **B** - To version-control SQL transformations
   *Explanation: dbt (data build tool) is designed to version-control, test, and document SQL transformations.*

4. **B** - Table
   *Explanation: Mart models are materialized as tables for fast query performance in BI tools.*

5. **B** - References another dbt model
   *Explanation: `{{ ref() }}` creates dependencies between dbt models and ensures correct order of execution.*

6. **B** - LEFT JOIN
   *Explanation: LEFT JOIN returns all rows from the left table plus matching rows from the right table.*

7. **B** - To truncate dates to a specified precision
   *Explanation: DATE_TRUNC reduces date precision (e.g., month, year) for aggregation.*

8. **C** - Pulses
   *Explanation: Pulses (now called Dashboard Subscriptions) send automated email reports.*

9. **B** - Organizing data to reduce redundancy
   *Explanation: Normalization organizes data to minimize redundancy and maintain integrity.*

10. **D** - Visualization
    *Explanation: dbt tests include unique, not_null, accepted_values, and custom tests, but not visualization.*

**True/False:**
11. **False** - dbt models can be views, tables, incremental, or ephemeral.

12. **False** - LEFT JOIN returns all rows from the left table plus matching right rows.

13. **True** - Metabase is open-source.

14. **False** - Staging models should be views (they should reflect source data).

15. **True** - Primary keys ensure uniqueness and data integrity.

**Fill in the Blank:**
16. `source()`
17. `intermediate`
18. `KPIs` or `headline metrics`
19. `up -d`
20. `COALESCE`

---

## MODULE 6.2 QUIZ: Analytics Storytelling

### Multiple Choice (10 Questions)

**1. What does the SCR framework stand for?**
- A) Situation, Challenge, Resolution
- B) Situation, Complication, Resolution
- C) Strategy, Challenge, Response
- D) Status, Complication, Response

**2. According to the 5-Minute Rule, executives should understand the core message within:**
- A) 30 seconds
- B) 5 minutes
- C) 15 minutes
- D) 30 minutes

**3. The 10/20/30 rule refers to:**
- A) 10 slides, 20 minutes, 30-point font
- B) 10 charts, 20 insights, 30 slides
- C) 10 pages, 20 minutes, 30 points
- D) 10 questions, 20 answers, 30 slides

**4. Which executive persona focuses on long-term growth and market leadership?**
- A) Operational CFO
- B) Customer-Focused CMO
- C) Visionary CEO
- D) Technical CTO

**5. "We're 97% certain this improvement is real" is a translation of:**
- A) R-squared = 0.85
- B) p-value = 0.03
- C) ROC AUC = 0.92
- D) Accuracy = 97%

**6. The "So What" test asks:**
- A) Who cares about this data?
- B) Why does this statistic matter for the business?
- C) What methodology was used?
- D) Who is the audience?

**7. What is the data-to-ink ratio?**
- A) How much data vs. how much ink is used
- B) Maximizing information per square inch of visual
- C) The ratio of data points to visual elements
- D) How much data is printed

**8. Which of the following is NOT recommended in executive communication?**
- A) Starting with the bottom line
- B) Using technical jargon
- C) Showing concrete numbers
- D) Being specific about recommendations

**9. A good executive summary should be:**
- A) 10+ pages with all details
- B) One page or less with bottom line first
- C) A technical report with methodology
- D) An email with bullet points

**10. The resolution section of an executive summary should include:**
- A) Methodology details
- B) Recommendations and expected impact
- C) Historical background
- D) Technical specifications

---

### True/False (5 Questions)

**11.** Stories are less memorable than facts and figures.
- [ ] True
- [ ] False

**12.** The complication section of SCR creates tension that requires resolution.
- [ ] True
- [ ] False

**13.** A p-value greater than 0.05 means the result is definitely real.
- [ ] True
- [ ] False

**14.** Executives should be given multiple options to choose from without a recommendation.
- [ ] True
- [ ] False

**15.** R-squared explains how much variance is accounted for by the model.
- [ ] True
- [ ] False

---

### Short Answer (5 Questions)

**16.** Briefly explain the SCR framework and why it's effective for executive communication.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**17.** What is the difference between correlation and causation? Why does this matter in business?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**18.** Translate the following to business language: "The model has an ROC AUC of 0.92."

```
_________________________________________________________________
_________________________________________________________________
```

**19.** What are the key elements of an effective executive summary?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**20.** Why is it important to tailor communication to different executive personas?

```
_________________________________________________________________
_________________________________________________________________
```

---

### Answer Key: Module 6.2 Quiz

**Multiple Choice:**
1. **B** - Situation, Complication, Resolution
   *Explanation: SCR is a storytelling framework that creates a narrative arc from current state to action.*

2. **B** - 5 minutes
   *Explanation: The 5-Minute Rule states executives should grasp the core message within 5 minutes.*

3. **A** - 10 slides, 20 minutes, 30-point font
   *Explanation: The 10/20/30 rule ensures presentations are concise, focused, and readable.*

4. **C** - Visionary CEO
   *Explanation: The Visionary CEO focuses on big picture, strategy, and long-term growth.*

5. **B** - p-value = 0.03
   *Explanation: p-value represents probability of results by chance. 0.03 means 97% confidence.*

6. **B** - Why does this statistic matter for the business?
   *Explanation: The "So What" test ensures every number has business relevance.*

7. **B** - Maximizing information per square inch of visual
   *Explanation: Data-to-ink ratio is about conveying maximum information with minimal visual clutter.*

8. **B** - Using technical jargon
   *Explanation: Technical jargon alienates executives and obscures your message.*

9. **B** - One page or less with bottom line first
   *Explanation: Executive summaries should be concise and lead with the conclusion.*

10. **B** - Recommendations and expected impact
    *Explanation: Resolution focuses on what to do and what impact it will have.*

**True/False:**
11. **False** - Stories are more memorable than facts and figures.

12. **True** - Complication creates tension that resolution must address.

13. **False** - p > 0.05 means the result is not statistically significant.

14. **False** - You should make a clear recommendation.

15. **True** - R-squared measures the proportion of variance explained.

**Short Answer:**
16. **Model Answer:** The SCR framework structures communication as: Situation (where we are now), Complication (what's changed or what's the problem), Resolution (what we should do). It's effective because it creates a logical narrative arc that mirrors how executives think about problems, builds tension, and leads to clear action.

17. **Model Answer:** Correlation means two variables move together, while causation means one directly causes the other. This matters because correlation alone doesn't justify intervention - you need to understand what's actually driving business outcomes to make effective decisions.

18. **Model Answer:** "Our model correctly distinguishes between positive and negative outcomes 92% of the time." or "We can reliably identify 92% of what we're trying to predict."

19. **Model Answer:** Key elements include: Situation (current state), Complication (problem/opportunity), Resolution (recommendations), Implementation (timeline/resources), and Decision Required (specific approval needed). It should be one page, bottom line first, and action-oriented.

20. **Model Answer:** Different executives have different priorities and concerns. Tailoring communication ensures your message resonates with their specific needs, increases engagement, and improves the likelihood of getting approval. One size does not fit all.

---

## MODULE 6.3 QUIZ: Data Ethics & Governance

### Multiple Choice (10 Questions)

**1. What is demographic parity?**
- A) Equal selection rates across groups
- B) Equal true positive rates across groups
- C) Equal false positive rates across groups
- D) Equal accuracy across groups

**2. What is the acceptable threshold for demographic parity difference?**
- A) < 0.01
- B) < 0.05
- C) < 0.10
- D) < 0.20

**3. Which of the following is NOT a protected attribute under fairness laws?**
- A) Race
- B) Gender
- C) Favorite color
- D) Age

**4. SHAP is based on which mathematical framework?**
- A) Game theory
- B) Graph theory
- C) Set theory
- D) Probability theory

**5. What does a positive SHAP value indicate?**
- A) The feature decreases the prediction
- B) The feature increases the prediction
- C) The feature has no impact
- D) The feature is not important

**6. Which privacy technique adds noise to protect individual data?**
- A) Anonymization
- B) Pseudonymization
- C) Differential Privacy
- D) Masking

**7. What is the GDPR breach notification timeline?**
- A) 24 hours
- B) 48 hours
- C) 72 hours
- D) 1 week

**8. Which fairness mitigation technique adjusts prediction thresholds?**
- A) Pre-processing
- B) In-processing
- C) Post-processing
- D) Re-training

**9. What is the role of a Data Protection Officer (DPO)?**
- A) To protect data from hackers
- B) To ensure regulatory compliance
- C) To manage databases
- D) To train staff

**10. Which type of privacy replaces identifiers with tokens?**
- A) Anonymization
- B) Pseudonymization
- C) Masking
- D) Aggregation

---

### True/False (5 Questions)

**11.** Fairness metrics alone can prove a model is completely unbiased.
- [ ] True
- [ ] False

**12.** LIME and SHAP are both model-agnostic explanation methods.
- [ ] True
- [ ] False

**13.** A model with high accuracy is always fair.
- [ ] True
- [ ] False

**14.** Anonymized data is completely irreversible.
- [ ] True
- [ ] False

**15.** GDPR applies only to companies based in Europe.
- [ ] True
- [ ] False

---

### Matching (5 Questions)

**16.** Match the fairness concept to its definition:

| Term | Definition |
|------|------------|
| A. Demographic Parity | 1. Equal true positive rates |
| B. Equal Opportunity | 2. Equal selection rates |
| C. Equalized Odds | 3. Equal error rates |
| D. Individual Fairness | 4. Similar individuals, similar outcomes |

A → ___
B → ___
C → ___
D → ___

**17.** Match the privacy technique to its description:

| Term | Description |
|------|-------------|
| A. Anonymization | 1. Add noise to protect privacy |
| B. Pseudonymization | 2. Remove identifying info |
| C. Differential Privacy | 3. Replace with random tokens |
| D. Masking | 4. Hide parts of data |

A → ___
B → ___
C → ___
D → ___

---

### Answer Key: Module 6.3 Quiz

**Multiple Choice:**
1. **A** - Equal selection rates across groups
   *Explanation: Demographic parity ensures the same proportion of positive outcomes across groups.*

2. **C** - < 0.10
   *Explanation: Demographic parity difference should be less than 0.10 for fairness.*

3. **C** - Favorite color
   *Explanation: Protected attributes typically include race, gender, age, religion, etc.*

4. **A** - Game theory
   *Explanation: SHAP is based on Shapley values from game theory.*

5. **B** - The feature increases the prediction
   *Explanation: Positive SHAP values increase the prediction probability.*

6. **C** - Differential Privacy
   *Explanation: Differential privacy adds controlled noise to protect individual data.*

7. **C** - 72 hours
   *Explanation: GDPR requires breach notification within 72 hours of discovery.*

8. **C** - Post-processing
   *Explanation: Post-processing adjusts predictions after model training.*

9. **B** - To ensure regulatory compliance
   *Explanation: DPOs oversee compliance with data protection regulations.*

10. **B** - Pseudonymization
    *Explanation: Pseudonymization replaces identifying information with pseudonyms.*

**True/False:**
11. **False** - Fairness is contextual and requires human assessment.

12. **True** - Both LIME and SHAP work with any model type.

13. **False** - High accuracy doesn't guarantee fairness.

14. **True** - Anonymized data cannot be re-identified.

15. **False** - GDPR applies to any company handling EU citizens' data.

**Matching:**
16. A → 2, B → 1, C → 3, D → 4

17. A → 2, B → 3, C → 1, D → 4

---

## MODULE 6.1 EXAM: BI Semantic Layers

### Section A: Multiple Choice (15 Questions)

**1. Which of the following is a dimension table in an e-commerce schema?**
- A) Orders
- B) Order Items
- C) Products
- D) Returns

**2. What is the primary purpose of an index?**
- A) To enforce referential integrity
- B) To speed up query execution
- C) To store data
- D) To manage transactions

**3. Which dbt materialization type is best for staging models?**
- A) Table
- B) View
- C) Incremental
- D) Ephemeral

**4. What does the `{{ source() }}` function in dbt reference?**
- A) Another dbt model
- B) A source table in the database
- C) A macro
- D) A seed file

**5. Which JOIN type returns all rows from both tables?**
- A) INNER JOIN
- B) LEFT JOIN
- C) RIGHT JOIN
- D) FULL OUTER JOIN

**6. What is the purpose of a primary key?**
- A) To uniquely identify each record
- B) To create an index
- C) To enforce foreign key relationships
- D) To compress data

**7. Which of the following is NOT a valid dbt test type?**
- A) Unique
- B) Not null
- C) Accepted values
- D) Data visualization

**8. What does the `docker-compose up -d` command do?**
- A) Stops all services
- B) Starts services in detached mode
- C) Deletes all containers
- D) Shows container logs

**9. Which SQL function is used to aggregate data by category?**
- A) ORDER BY
- B) GROUP BY
- C) WHERE
- D) JOIN

**10. What is the difference between a view and a table?**
- A) Views store data, tables don't
- B) Views are stored queries, tables store data
- C) Views are faster than tables
- D) There is no difference

**11. Which Metabase feature allows users to create interactive visualizations?**
- A) Questions
- B) Collections
- C) Dashboards
- D) Pulses

**12. What is the purpose of a CTE (Common Table Expression)?**
- A) To create a temporary result set
- B) To create a new table
- C) To delete data
- D) To update data

**13. Which of the following is a fact table?**
- A) Customers
- B) Products
- C) Orders
- D) Categories

**14. What does the `HAVING` clause do?**
- A) Filters individual rows
- B) Filters grouped results
- C) Orders results
- D) Joins tables

**15. Which SQL function calculates the average of a numeric column?**
- A) COUNT
- B) SUM
- C) AVG
- D) MAX

---

### Section B: True/False (10 Questions)

**16.** dbt models must always be materialized as tables.
- [ ] True
- [ ] False

**17.** A LEFT JOIN returns all rows from the left table, even if there are no matches in the right table.
- [ ] True
- [ ] False

**18.** PostgreSQL supports full-text search.
- [ ] True
- [ ] False

**19.** dbt testing can only be done manually by checking the data.
- [ ] True
- [ ] False

**20.** A well-designed dashboard should use as many colors as possible.
- [ ] True
- [ ] False

**21.** Indexes should be created on columns used in WHERE clauses.
- [ ] True
- [ ] False

**22.** Metabase can only be used with PostgreSQL databases.
- [ ] True
- [ ] False

**23.** The `COALESCE` function returns the first non-null value.
- [ ] True
- [ ] False

**24.** Materialized views store data physically.
- [ ] True
- [ ] False

**25.** Third normal form (3NF) eliminates transitive dependencies.
- [ ] True
- [ ] False

---

### Section C: Fill in the Blank (10 Questions)

**26.** The dbt function to reference another model is {{ __________ }}.

**27.** The SQL keyword that removes duplicate rows is __________.

**28.** The Docker command to view logs from all services is `docker-compose __________`.

**29.** The Metabase feature for automated email reports is called __________.

**30.** The database normalization form that eliminates partial dependencies is __________.

**31.** The SQL function that returns the current date and time is __________.

**32.** In dbt, staging models should be materialized as __________.

**33.** The JOIN type that returns only matching rows from both tables is __________.

**34.** The command to generate dbt documentation is `dbt docs __________`.

**35.** The SQL function that handles NULL values by providing a default is __________.

---

### Section D: Short Answer (5 Questions)

**36.** Explain the difference between staging, intermediate, and mart models in dbt. Give an example of each.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**37.** Describe the process of setting up a Metabase dashboard. What are the key considerations?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**38.** What is database normalization? Why is it important for analytics?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**39.** Explain the role of indexes in query performance. When should you create them?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**40.** How would you optimize a slow-performing dashboard? List at least 5 strategies.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## MODULE 6.2 EXAM: Analytics Storytelling

### Section A: Multiple Choice (15 Questions)

**1. What is the primary goal of analytics storytelling?**
- A) To present all the data
- B) To drive business decisions
- C) To show technical expertise
- D) To demonstrate accuracy

**2. In the SCR framework, what does the "Complication" represent?**
- A) The current state
- B) The problem or opportunity
- C) The recommended action
- D) The expected outcome

**3. Which of the following is an example of statistical translation?**
- A) "The p-value is 0.03"
- B) "We're 97% confident this improvement is real"
- C) "The model has 15 features"
- D) "The data was split 80/20"

**4. What is a key characteristic of an effective executive summary?**
- A) It includes all methodology details
- B) It leads with the conclusion
- C) It is at least 10 pages
- D) It uses technical terminology

**5. According to the 10/20/30 rule, how many slides should a presentation have?**
- A) 10
- B) 20
- C) 30
- D) 15

**6. Which executive persona is most concerned with cost efficiency?**
- A) Visionary CEO
- B) Operational CFO
- C) Customer-Focused CMO
- D) Technical CTO

**7. What is the "So What" test?**
- A) Testing stakeholder interest
- B) Connecting data to business outcomes
- C) Testing hypothesis significance
- D) Evaluating presentation delivery

**8. Which of the following is NOT a component of the 5 Sentences Framework?**
- A) The problem we're solving
- B) What we found
- C) The methodology used
- D) What we need from you

**9. What does R-squared measure?**
- A) Correlation strength
- B) Variance explained
- C) Prediction accuracy
- D) Model complexity

**10. Which chart type is best for showing trends over time?**
- A) Pie chart
- B) Line chart
- C) Bar chart
- D) Scatter plot

**11. What should be included in the "Resolution" section of an executive summary?**
- A) Historical background
- B) Recommendations and impact
- C) Methodology details
- D) Technical specifications

**12. Which of the following is a best practice for presenting to executives?**
- A) Starting with methodology
- B) Using technical jargon
- C) Showing the bottom line first
- D) Providing multiple options

**13. What is the significance of the p-value in hypothesis testing?**
- A) It proves the hypothesis is correct
- B) It measures the probability of results by chance
- C) It calculates the effect size
- D) It determines sample size

**14. Which of the following is NOT an effective way to build credibility?**
- A) Knowing your numbers
- B) Admitting what you don't know
- C) Being defensive about questions
- D) Having backup data

**15. What is the purpose of the "Call to Action" in a presentation?**
- A) To end the presentation
- B) To request a specific decision
- C) To summarize the data
- D) To thank the audience

---

### Section B: True/False (10 Questions)

**16.** Stories are less memorable than facts and figures.
- [ ] True
- [ ] False

**17.** The complication in SCR should create tension that requires resolution.
- [ ] True
- [ ] False

**18.** A p-value greater than 0.05 means the result is definitely real.
- [ ] True
- [ ] False

**19.** Correlation is sufficient evidence for causation.
- [ ] True
- [ ] False

**20.** Executive summaries should be written in technical language.
- [ ] True
- [ ] False

**21.** Data visualizations should have a clear headline or insight.
- [ ] True
- [ ] False

**22.** The CFO is primarily concerned with customer acquisition.
- [ ] True
- [ ] False

**23.** R-squared can be negative.
- [ ] True
- [ ] False

**24.** The 5-Minute Rule states executives should understand the core message within 5 minutes.
- [ ] True
- [ ] False

**25.** Every statistic should answer "So what?" for the business.
- [ ] True
- [ ] False

---

### Section C: Short Answer (10 Questions)

**26.** Explain the SCR framework and why it's effective for executive communication.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**27.** Provide 5 examples of translating statistical terms to business language.

```
1. _____________________________________________________________
2. _____________________________________________________________
3. _____________________________________________________________
4. _____________________________________________________________
5. _____________________________________________________________
```

**28.** Describe the key elements of an executive summary for a customer retention initiative.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**29.** How would you tailor a presentation for a Visionary CEO versus an Operational CFO?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**30.** Explain the difference between correlation and causation. Why is this distinction important?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**31.** Design a 7-slide executive presentation outline for a churn reduction project.

```
Slide 1: _________________________________________________________
Slide 2: _________________________________________________________
Slide 3: _________________________________________________________
Slide 4: _________________________________________________________
Slide 5: _________________________________________________________
Slide 6: _________________________________________________________
Slide 7: _________________________________________________________
```

**32.** What are the key considerations when designing a data visualization for executives?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**33.** Describe the components of an effective executive summary.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**34.** How do you handle a question you don't know the answer to in an executive meeting?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**35.** What is the significance of the data-to-ink ratio in visualization design?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## MODULE 6.3 EXAM: Data Ethics & Governance

### Section A: Multiple Choice (15 Questions)

**1. What is demographic parity?**
- A) Equal true positive rates across groups
- B) Equal selection rates across groups
- C) Equal false positive rates across groups
- D) Equal model accuracy across groups

**2. Which of the following is a protected attribute under most fairness frameworks?**
- A) Zip code
- B) Favorite color
- C) Pet ownership
- D) Race

**3. What is the acceptable threshold for demographic parity difference?**
- A) < 0.01
- B) < 0.05
- C) < 0.10
- D) < 0.20

**4. SHAP values are based on which mathematical concept?**
- A) Shapley values
- B) Shannon entropy
- C) Bayes theorem
- D) Gradient descent

**5. What does a positive SHAP value indicate?**
- A) The feature increases the prediction
- B) The feature decreases the prediction
- C) The feature has no impact
- D) The feature is not important

**6. Which privacy technique adds controlled noise to protect individual data?**
- A) Anonymization
- B) Pseudonymization
- C) Differential Privacy
- D) Data masking

**7. What is the GDPR breach notification timeline?**
- A) 24 hours
- B) 48 hours
- C) 72 hours
- D) 7 days

**8. Which fairness mitigation technique adjusts model predictions?**
- A) Pre-processing
- B) In-processing
- C) Post-processing
- D) Data augmentation

**9. What is the role of a Model Card?**
- A) To store model weights
- B) To document model details and performance
- C) To deploy models
- D) To train models

**10. Which type of privacy replaces identifying information with tokens?**
- A) Anonymization
- B) Pseudonymization
- C) Masking
- D) Aggregation

**11. What is the purpose of equalized odds?**
- A) Equal selection rates across groups
- B) Equal error rates across groups
- C) Equal true positive rates only
- D) Equal accuracy across groups

**12. Which of the following is NOT a GDPR requirement?**
- A) Right to access
- B) Right to erasure
- C) Right to a jury trial
- D) Right to portability

**13. What is the relationship between epsilon and privacy in differential privacy?**
- A) Smaller epsilon = more privacy
- B) Larger epsilon = more privacy
- C) Epsilon doesn't affect privacy
- D) Epsilon and privacy are inversely related

**14. What is the purpose of a fairness audit?**
- A) To improve model accuracy
- B) To detect and mitigate bias
- C) To deploy models faster
- D) To reduce model complexity

**15. Which of the following is NOT a valid fairness metric?**
- A) Demographic parity
- B) Equal opportunity
- C) Equalized odds
- D) Equal accuracy

---

### Section B: True/False (10 Questions)

**16.** A model with high accuracy is always fair.
- [ ] True
- [ ] False

**17.** SHAP can only be used with tree-based models.
- [ ] True
- [ ] False

**18.** Differential privacy adds noise to protect individual privacy.
- [ ] True
- [ ] False

**19.** GDPR only applies to companies in Europe.
- [ ] True
- [ ] False

**20.** Anonymized data can be re-identified.
- [ ] True
- [ ] False

**21.** LIME is a local explanation method.
- [ ] True
- [ ] False

**22.** A lower epsilon value in differential privacy means stronger privacy protection.
- [ ] True
- [ ] False

**23.** The Data Protection Officer is responsible for data storage.
- [ ] True
- [ ] False

**24.** Fairness constraints can be added during model training.
- [ ] True
- [ ] False

**25.** Privacy and data protection are optional in AI development.
- [ ] True
- [ ] False

---

### Section C: Matching (10 Questions)

**26.** Match the privacy technique to its description:

| Technique | Description |
|-----------|-------------|
| A. Anonymization | 1. Add noise to protect privacy |
| B. Pseudonymization | 2. Remove identifying info |
| C. Differential Privacy | 3. Replace with tokens |
| D. Data Masking | 4. Hide parts of data |

A → ___
B → ___
C → ___
D → ___

**27.** Match the fairness concept to its definition:

| Concept | Definition |
|---------|------------|
| A. Demographic Parity | 1. Equal true positive rates |
| B. Equal Opportunity | 2. Equal selection rates |
| C. Equalized Odds | 3. Equal error rates |
| D. Individual Fairness | 4. Similar outcomes for similar individuals |

A → ___
B → ___
C → ___
D → ___

**28.** Match the mitigation technique to its timing:

| Technique | Timing |
|-----------|--------|
| A. Reweighting | 1. During model training |
| B. Fairness Constraints | 2. Before model training |
| C. Threshold Adjustment | 3. After model training |

A → ___
B → ___
C → ___

---

### Section D: Short Answer (5 Questions)

**29.** Describe the process of conducting a fairness audit. What are the key steps?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**30.** Explain the difference between LIME and SHAP. When would you use each?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**31.** What are the key requirements of GDPR? How do they impact data analytics?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**32.** How does differential privacy work? Provide an example of when it might be used.

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**33.** What are the components of a model governance framework? Why is model governance important?

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## FINAL EXAM: COMPREHENSIVE COURSE ASSESSMENT

### Section A: Multiple Choice (30 Questions)

**1. What is a semantic layer?**
- A) A physical storage layer
- B) A business-friendly data abstraction
- C) A database optimization
- D) A visualization tool

**2. Which dbt model type cleans raw data?**
- A) Mart model
- B) Intermediate model
- C) Staging model
- D) Source model

**3. What does the SCR framework stand for?**
- A) Situation, Challenge, Resolution
- B) Situation, Complication, Resolution
- C) Strategy, Challenge, Response
- D) Status, Complication, Response

**4. What is the 5-Minute Rule?**
- A) Executives should have 5 minutes to ask questions
- B) Core message should be understood in 5 minutes
- C) Presentations should be 5 minutes long
- D) Data should be collected in 5 minutes

**5. What is demographic parity?**
- A) Equal true positive rates across groups
- B) Equal selection rates across groups
- C) Equal accuracy across groups
- D) Equal false positive rates

**6. What does a positive SHAP value indicate?**
- A) Feature decreases prediction
- B) Feature increases prediction
- C) Feature has no impact
- D) Feature is not important

**7. What is the GDPR breach notification timeline?**
- A) 24 hours
- B) 48 hours
- C) 72 hours
- D) 1 week

**8. Which JOIN type returns all rows from the left table?**
- A) INNER JOIN
- B) LEFT JOIN
- C) RIGHT JOIN
- D) FULL OUTER JOIN

**9. What is the purpose of a primary key?**
- A) To create an index
- B) To uniquely identify records
- C) To enforce foreign keys
- D) To compress data

**10. What does the `{{ ref() }}` function do in dbt?**
- A) References a source table
- B) References another dbt model
- C) Creates a new table
- D) Drops a table

**11. Which executive persona focuses on long-term growth?**
- A) CFO
- B) CMO
- C) CEO
- D) CTO

**12. What is the acceptable threshold for demographic parity difference?**
- A) < 0.01
- B) < 0.05
- C) < 0.10
- D) < 0.20

**13. Which privacy technique adds noise to protect data?**
- A) Anonymization
- B) Pseudonymization
- C) Differential Privacy
- D) Masking

**14. What is the purpose of a materialized view?**
- A) To store a query result physically
- B) To create a temporary table
- C) To index data
- D) To compress data

**15. What is the data-to-ink ratio?**
- A) Ratio of data to visualization
- B) Maximizing information per visual
- C) Amount of data printed
- D) Number of data points

**16. Which of the following is NOT a protected attribute?**
- A) Race
- B) Gender
- C) Favorite color
- D) Age

**17. What is the role of a Data Protection Officer?**
- A) To protect data from hackers
- B) To ensure regulatory compliance
- C) To manage databases
- D) To train staff

**18. Which chart type is best for showing trends?**
- A) Pie chart
- B) Line chart
- C) Bar chart
- D) Scatter plot

**19. What is the purpose of an index?**
- A) To enforce referential integrity
- B) To speed up query execution
- C) To store data
- D) To manage transactions

**20. What is the 10/20/30 rule?**
- A) 10 slides, 20 minutes, 30-point font
- B) 10 charts, 20 insights, 30 slides
- C) 10 pages, 20 minutes, 30 points
- D) 10 questions, 20 answers, 30 slides

**21. What does equalized odds require?**
- A) Equal selection rates
- B) Equal true positive rates
- C) Equal error rates across groups
- D) Equal accuracy

**22. Which of the following is NOT a dbt test type?**
- A) Unique
- B) Not null
- C) Visualization
- D) Accepted values

**23. What is pseudonymization?**
- A) Removing all identifying information
- B) Replacing identifiers with tokens
- C) Adding noise to data
- D) Hiding parts of data

**24. Which JOIN type returns all rows from both tables?**
- A) INNER JOIN
- B) LEFT JOIN
- C) RIGHT JOIN
- D) FULL OUTER JOIN

**25. What is the "So What" test?**
- A) Testing stakeholder interest
- B) Connecting data to business outcomes
- C) Testing hypothesis significance
- D) Evaluating presentation delivery

**26. Which fairness mitigation technique adjusts predictions?**
- A) Pre-processing
- B) In-processing
- C) Post-processing
- D) Data augmentation

**27. What is the purpose of a Model Card?**
- A) To store model weights
- B) To document model details
- C) To deploy models
- D) To train models

**28. What does the `DATE_TRUNC` function do?**
- A) Deletes dates
- B) Truncates dates to specified precision
- C) Adds days to dates
- D) Converts dates to strings

**29. Which of the following is NOT a GDPR requirement?**
- A) Right to access
- B) Right to erasure
- C) Right to jury trial
- D) Right to portability

**30. What is the purpose of a fairness audit?**
- A) To improve model accuracy
- B) To detect and mitigate bias
- C) To deploy models faster
- D) To reduce model complexity

---

### Section B: True/False (10 Questions)

**31.** dbt models can only be materialized as views.
- [ ] True
- [ ] False

**32.** A high-accuracy model is always fair.
- [ ] True
- [ ] False

**33.** GDPR applies to any company handling EU citizens' data.
- [ ] True
- [ ] False

**34.** SHAP can only be used with tree-based models.
- [ ] True
- [ ] False

**35.** Stories are more memorable than facts and figures.
- [ ] True
- [ ] False

**36.** Correlation is sufficient evidence for causation.
- [ ] True
- [ ] False

**37.** Anonymized data can be re-identified.
- [ ] True
- [ ] False

**38.** The complication in SCR creates tension.
- [ ] True
- [ ] False

**39.** LIME is a global explanation method.
- [ ] True
- [ ] False

**40.** Third normal form eliminates transitive dependencies.
- [ ] True
- [ ] False

---

### Section C: Fill in the Blank (10 Questions)

**41.** The dbt function for referencing another model is {{ __________ }}.

**42.** The SQL keyword that removes duplicates is __________.

**43.** SCR stands for Situation, __________, Resolution.

**44.** The 5-Minute Rule states executives should understand the core message within __________ minutes.

**45.** The acceptable threshold for demographic parity difference is < __________.

**46.** __________ adds controlled noise to protect individual privacy.

**47.** The GDPR breach notification timeline is __________ hours.

**48.** __________ is the standard for model interpretability based on game theory.

**49.** A __________ JOIN returns all rows from the left table and matching rows from the right.

**50.** __________ optimization involves adjusting prediction thresholds for fairness.

---

## COMPREHENSIVE ANSWER KEY

### Final Exam Answer Key

**Multiple Choice:**
1. B
2. C
3. B
4. B
5. B
6. B
7. C
8. B
9. B
10. B
11. C
12. C
13. C
14. A
15. B
16. C
17. B
18. B
19. B
20. A
21. C
22. C
23. B
24. D
25. B
26. C
27. B
28. B
29. C
30. B

**True/False:**
31. False
32. False
33. True
34. False
35. True
36. False
37. True
38. True
39. False
40. True

**Fill in the Blank:**
41. `ref()`
42. `DISTINCT`
43. `Complication`
44. `5`
45. `0.10`
46. `Differential Privacy`
47. `72`
48. `SHAP`
49. `LEFT`
50. `Post-processing`

---

## CODING CHALLENGES

### Challenge 1: dbt Model Creation

**Task:** Write a complete dbt staging model for the `orders` table.

```sql
-- Write your complete staging model here:













```

**Answer Key:**
```sql
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'orders') }}
),

renamed AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        status,
        payment_method,
        payment_status,
        subtotal_amount,
        tax_amount,
        shipping_amount,
        discount_amount,
        total_amount,
        CASE
            WHEN subtotal_amount > 0 
            THEN ROUND((discount_amount / subtotal_amount) * 100, 2)
            ELSE 0
        END AS discount_rate,
        DATE_TRUNC('month', order_date) AS order_month,
        EXTRACT(YEAR FROM order_date) AS order_year,
        created_at,
        updated_at
    FROM source
)

SELECT * FROM renamed
```

---

### Challenge 2: SHAP Implementation

**Task:** Complete the SHAP implementation for a churn model.

```python
import shap
import pandas as pd
import numpy as np

# Load model and data
model = _________
X_test = _________
feature_names = _________

# Create SHAP explainer
explainer = _________
shap_values = _________

# Generate summary plot
shap._________(shap_values, X_test, feature_names=feature_names)

# Calculate feature importance
importance = np._________(shap_values, axis=0)
ranked_features = sorted(zip(_________, _________), key=lambda x: x[1], reverse=True)

print("Top 5 Features:")
for feature, imp in ranked_features[:5]:
    print(f"  {feature}: {imp:.3f}")
```

**Answer Key:**
```python
import shap
import pandas as pd
import numpy as np

# Load model and data
model = loaded_model
X_test = test_data
feature_names = test_data.columns.tolist()

# Create SHAP explainer
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)

# Generate summary plot
shap.summary_plot(shap_values, X_test, feature_names=feature_names)

# Calculate feature importance
importance = np.abs(shap_values).mean(axis=0)
ranked_features = sorted(zip(feature_names, importance), key=lambda x: x[1], reverse=True)

print("Top 5 Features:")
for feature, imp in ranked_features[:5]:
    print(f"  {feature}: {imp:.3f}")
```

---

### Challenge 3: Fairness Analysis

**Task:** Complete the fairness analysis code.

```python
from fairlearn.metrics import (
    demographic_parity_difference,
    equalized_odds_difference
)

# Load data
y_true = _________
y_pred = _________
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

print(f"Demographic Parity Difference: {dp_diff:.3f}")
print(f"Equalized Odds Difference: {eo_diff:.3f}")

if dp_diff < _________:
    print("✅ Demographic parity satisfied")
else:
    print("⚠️ Demographic parity violation detected")
```

**Answer Key:**
```python
from fairlearn.metrics import (
    demographic_parity_difference,
    equalized_odds_difference
)

# Load data
y_true = y_test
y_pred = model.predict(X_test)
groups = protected_groups

# Calculate fairness metrics
dp_diff = demographic_parity_difference(
    y_true=y_true,
    y_pred=y_pred,
    sensitive_features=groups
)

eo_diff = equalized_odds_difference(
    y_true=y_true,
    y_pred=y_pred,
    sensitive_features=groups
)

print(f"Demographic Parity Difference: {dp_diff:.3f}")
print(f"Equalized Odds Difference: {eo_diff:.3f}")

if dp_diff < 0.10:
    print("✅ Demographic parity satisfied")
else:
    print("⚠️ Demographic parity violation detected")
```

---

## CASE STUDIES

### Case Study 1: Customer Churn Initiative

**Scenario:** You are leading a data science team at a SaaS company. The CFO has asked you to analyze customer churn and recommend strategies to reduce it by 30% within 12 months.

**Data Available:**
- 5,000 customers
- Monthly churn rate: 3.5%
- Average customer lifetime: 18 months
- Average revenue per customer: $850/year
- Historical data: 3 years of customer activity

**Questions:**

**1. What KPIs would you track for this initiative?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**2. What data would you need to analyze churn drivers?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**3. How would you present your recommendations to the CFO?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**4. What fairness considerations would you need to address?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**5. What is the financial impact of reducing churn by 30%?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**Answer Key:**

**1. KPIs to track:**
- Monthly churn rate (target: 2.45%)
- Customer lifetime value (target: $1,100)
- Retention rate (target: 80%)
- Customer health score
- NPS score
- Time to value

**2. Data needed:**
- Customer demographics
- Usage patterns
- Support interactions
- Payment history
- Product feedback
- Competitor activity

**3. Presentation to CFO:**
- Show current churn impact ($1.5M annual loss)
- Present SCR framework: Situation (current churn), Complication (impact), Resolution (recommendations)
- Show ROI: $450K investment, $1.35M annual savings
- Provide implementation roadmap

**4. Fairness considerations:**
- Ensure model doesn't discriminate by demographic factors
- Monitor predictions across customer segments
- Regular fairness audits
- Transparent decision-making

**5. Financial impact:**
- Current churn: 3.5% of 5,000 = 175 customers/year
- Revenue impact: 175 × $850 = $148,750/year
- 30% reduction saves: $44,625/year
- Over 3 years: $133,875

---

### Case Study 2: Model Explainability

**Scenario:** Your team has built a loan approval model. The compliance officer has asked you to explain how the model makes decisions and demonstrate it's fair.

**Model Details:**
- XGBoost classifier
- 25 features
- 89% accuracy
- Loans approved: 15% of applicants

**Questions:**

**1. How would you explain the model's decisions to the compliance officer?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**2. What fairness metrics would you calculate?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**3. How would you demonstrate that the model is fair?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**4. What documentation would you provide?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**5. How would you handle a complaint from a rejected applicant?**

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

**Answer Key:**

**1. Explain to compliance officer:**
- Use SHAP to show feature importance
- Demonstrate how features affect predictions
- Provide both global and local explanations
- Use business-friendly language

**2. Fairness metrics:**
- Demographic parity (selection rates)
- Equalized odds (error rates)
- Disparate impact ratio
- Group performance comparisons

**3. Demonstrate fairness:**
- Calculate metrics for all protected groups
- Show all metrics are within acceptable thresholds
- Document any mitigation applied
- Provide evidence of ongoing monitoring

**4. Documentation:**
- Model Card (performance, limitations)
- Data Card (training data details)
- Fairness Report (metrics, mitigation)
- Compliance certification

**5. Handle complaint:**
- Provide SHAP explanation for the specific decision
- Offer to review the decision
- Explain the factors that led to rejection
- Provide recourse options
- Maintain audit trail

---

## GRADING RUBRIC

### Module Quizzes
- 20 questions × 5 points = 100 points
- Time: 30 minutes
- Passing: 70%

### Module Exams
- 40 questions × 2.5 points = 100 points
- Time: 60 minutes
- Passing: 70%

### Final Exam
- 50 questions × 2 points = 100 points
- Time: 90 minutes
- Passing: 70%

### Coding Challenges
- 10 points each
- Evaluated on:
  - Correctness (40%)
  - Completeness (30%)
  - Best practices (30%)

### Case Studies
- 20 points each
- Evaluated on:
  - Application of concepts (30%)
  - Reasoning and justification (30%)
  - Practical relevance (20%)
  - Clarity of communication (20%)

---

## CERTIFICATE OF COMPLETION

This is to certify that

**__________________________**

has successfully completed the

**Executive Decision Pipeline Course**

demonstrating proficiency in:

- [ ] BI Semantic Layers & dbt
- [ ] Data Visualization & Dashboards
- [ ] Analytics Storytelling
- [ ] Executive Communication
- [ ] Data Ethics & Fairness
- [ ] Model Explainability
- [ ] Privacy & Governance
- [ ] Executive Decision Pack Creation

**Date:** __________________

**Grade:** __________________

**Instructor:** __________________

*This comprehensive test bank provides over 300 questions covering all aspects of the Executive Decision Pipeline course. Use it for assessment, review, and certification preparation.*
