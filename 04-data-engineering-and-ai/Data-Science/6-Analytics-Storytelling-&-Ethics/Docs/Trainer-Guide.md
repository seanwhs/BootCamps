# Executive Decision Pipeline: Trainer Guide
## Complete Instructor's Manual

---

## How to Use This Trainer Guide

This comprehensive trainer guide provides everything you need to deliver the Executive Decision Pipeline course effectively. It contains:

1. **Course Overview** - Complete course architecture
2. **Lesson Plans** - Detailed session-by-session plans
3. **Teaching Tips** - Best practices for instruction
4. **Common Pitfalls** - Student issues and solutions
5. **Discussion Questions** - Engaging class discussions
6. **Group Activities** - Collaborative learning exercises
7. **Assessment Guide** - Grading and evaluation
8. **Course Modifications** - Adapting for different audiences
9. **Troubleshooting** - Technical and instructional issues
10. **Feedback Forms** - Course evaluation templates

### For New Instructors

- **Start with Part 1:** Understand the course architecture
- **Review lesson plans:** Each session is fully scripted
- **Practice the exercises:** Complete them yourself first
- **Anticipate questions:** Review common pitfalls
- **Have backup resources:** Use the references guide

### For Experienced Instructors

- **Customize lesson plans:** Adapt to your audience
- **Add your examples:** Make it relevant to your students
- **Skip or expand:** Based on student needs
- **Use case studies:** From your own experience

---

## PART 1: COURSE OVERVIEW

### Course Description

The Executive Decision Pipeline is a comprehensive, hands-on course that bridges the gap between data engineering and executive decision-making. Students learn to build self-service BI environments, communicate complex analytics to executives, and ensure ethical, explainable AI.

### Target Audience

| Criteria | Description |
|----------|-------------|
| **Role** | Advanced analysts, data scientists, aspiring data leaders |
| **Experience** | 2-5 years in data analytics/science |
| **Prerequisites** | Python, SQL, basic statistics |
| **Interest** | Data engineering, BI, executive communication |

### Learning Objectives

By the end of this course, students will be able to:

1. **Module 6.1:** Build and deploy a production-grade BI semantic layer with dbt and create interactive dashboards with Metabase
2. **Module 6.2:** Structure and deliver compelling executive communications using the SCR framework
3. **Module 6.3:** Audit models for fairness, generate SHAP explainability reports, and implement privacy-preserving techniques
4. **Capstone:** Integrate all skills into a comprehensive Executive Decision Pack

### Course Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                     COURSE STRUCTURE                               │
├─────────────────────────────────────────────────────────────────────┤
│  Module 6.1: BI Semantic Layers (4 hours)                         │
│  ├── Lecture 1: Introduction (30 min)                             │
│  ├── Lecture 2: Database Setup (45 min)                           │
│  ├── Lecture 3: dbt Semantic Layer (60 min)                       │
│  ├── Lecture 4: Dashboard Creation (45 min)                       │
│  ├── Lab: Build Your Dashboard (60 min)                           │
│  └── Assessment: Quiz (30 min)                                    │
├─────────────────────────────────────────────────────────────────────┤
│  Module 6.2: Analytics Storytelling (3 hours)                     │
│  ├── Lecture 1: The Art of Storytelling (30 min)                  │
│  ├── Lecture 2: Understanding Your Audience (30 min)              │
│  ├── Lecture 3: Translating Statistics (30 min)                   │
│  ├── Lecture 4: Executive Summaries (30 min)                      │
│  ├── Lab: Write Executive Summary (45 min)                        │
│  └── Assessment: Quiz (30 min)                                    │
├─────────────────────────────────────────────────────────────────────┤
│  Module 6.3: Data Ethics & Governance (4 hours)                   │
│  ├── Lecture 1: AI Ethics Intro (30 min)                          │
│  ├── Lecture 2: Fairness Analysis (45 min)                        │
│  ├── Lecture 3: Explainability (45 min)                           │
│  ├── Lecture 4: Privacy & Governance (30 min)                     │
│  ├── Lab: Fairness & SHAP (60 min)                                │
│  └── Assessment: Quiz (30 min)                                    │
├─────────────────────────────────────────────────────────────────────┤
│  Capstone: Executive Decision Pack (5 hours)                      │
│  ├── Integration (60 min)                                         │
│  ├── Generation (60 min)                                          │
│  ├── Review & Polish (60 min)                                     │
│  ├── Presentation Prep (60 min)                                   │
│  └── Final Presentation (60 min)                                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Course Materials

| Material | Purpose | Format |
|----------|---------|--------|
| **Slide Deck** | In-class instruction | PowerPoint/PDF |
| **Student Workbook** | Hands-on exercises | PDF |
| **Student Notes** | Lecture summaries | PDF |
| **Quiz & Test Bank** | Assessment | DOCX/PDF |
| **References Guide** | Continued learning | PDF |
| **Code Repository** | Code examples | GitHub |
| **Sample Data** | Practice data | CSV/SQL |
| **Templates** | Executive documents | DOCX/MD |

---

## PART 2: LESSON PLANS

### Module 6.1: BI Semantic Layers

#### Session 1.1: Introduction (30 minutes)

**Learning Objectives:**
- Understand what a semantic layer is and why it matters
- See the course architecture and project structure
- Set up the development environment

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Welcome & Course Intro | Instructor presentation |
| 5-10 min | What is a Semantic Layer? | Instructor presentation, analogy |
| 10-15 min | Why Semantic Layers Matter | Discussion: "What's your experience with inconsistent metrics?" |
| 15-20 min | Course Architecture Overview | Diagram walkthrough |
| 20-25 min | Technology Stack Overview | Quick tour of tools |
| 25-30 min | Environment Setup Demo | Live demo of project creation |

**Key Teaching Points:**
- Semantic layers are "business-friendly abstractions"
- Centralized definitions = single source of truth
- Self-service analytics empowers everyone
- We'll use dbt + Metabase + PostgreSQL

**Class Discussion Questions:**
1. "What's your experience with inconsistent metrics across your organization?"
2. "How much time do you spend defining metrics vs. analyzing them?"
3. "What would self-service analytics enable for your stakeholders?"

**Common Pitfalls:**
- Students may not understand the need for a semantic layer
- Some may have experience with Looker or Tableau but not dbt
- Technical setup issues may arise - have Docker ready

**Materials:**
- Slides 1-25 (Course Introduction)
- Docker desktop installed
- VS Code with Python extension

---

#### Session 1.2: Database Setup (45 minutes)

**Learning Objectives:**
- Set up PostgreSQL using Docker Compose
- Design a normalized database schema
- Generate and load sample data

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review previous session |
| 5-10 min | Why Docker? | Instructor presentation |
| 10-15 min | Docker Compose Setup | Live demo |
| 15-25 min | Schema Design | Group activity: Design schema for e-commerce |
| 25-35 min | Data Generation | Walk through Python script |
| 35-40 min | Verification | Run verification commands |
| 40-45 min | Q&A | Open discussion |

**Key Teaching Points:**
- Docker ensures consistency across environments
- Normalization reduces redundancy, ensures integrity
- 3NF is the standard for analytics
- UUIDs are better than serial keys for distributed systems
- Indexes are critical for performance

**Class Activity: Database Schema Design**
1. Break students into groups
2. Ask them to design a schema for an e-commerce database
3. Have them identify dimension and fact tables
4. Discuss relationships and foreign keys
5. Compare with the course schema

**Common Pitfalls:**
- Docker may not be installed or configured correctly
- Port conflicts (5432, 3000)
- Memory issues with Docker on some machines
- Students may struggle with normalization concepts

**Troubleshooting Tips:**
```bash
# Check Docker status
docker --version
docker-compose --version

# Check port conflicts
sudo lsof -i :5432
sudo lsof -i :3000

# Check logs
docker-compose logs postgres
docker-compose logs metabase
```

**Materials:**
- Slides 26-45
- Docker installation guide
- PostgreSQL schema script
- Sample data generation script

---

#### Session 1.3: dbt Semantic Layer (60 minutes)

**Learning Objectives:**
- Install and configure dbt
- Create staging, intermediate, and mart models
- Test and document dbt models

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review previous session |
| 5-10 min | What is dbt? | Instructor presentation |
| 10-15 min | dbt Installation & Setup | Live demo |
| 15-30 min | Building Staging Models | Live coding + student practice |
| 30-40 min | Building Intermediate Models | Live coding + student practice |
| 40-50 min | Building Mart Models | Live coding + student practice |
| 50-55 min | Testing & Documentation | Demonstration |
| 55-60 min | Q&A | Open discussion |

**Key Teaching Points:**
- dbt = version-controlled SQL transformations
- Staging = clean raw data (views)
- Intermediate = combine sources (views)
- Mart = business-ready (tables)
- Tests ensure data quality
- Documentation is auto-generated

**dbt Commands to Demo:**

```bash
# Installation
pip install dbt-postgres==1.6.0

# Init
dbt init analytics_dbt

# Profile setup
# ~/.dbt/profiles.yml

# Run models
dbt run --project-dir .
dbt run --models staging
dbt run --models +dm_customer_360

# Test
dbt test --project-dir .

# Documentation
dbt docs generate --project-dir .
dbt docs serve --project-dir . --port 8080
```

**Student Practice:**
1. Create a staging model for `orders`
2. Create an intermediate model for customer summary
3. Create a mart model for customer 360
4. Add tests for the models
5. Generate documentation

**Common Pitfalls:**
- Students forget `{{ ref() }}` in dbt models
- Connection issues with profiles.yml
- Wrong materialization (view vs. table)
- Not handling null values
- Inefficient joins (missing indexes)

**Troubleshooting Tips:**
```bash
# Debug connection
dbt debug --project-dir .

# Check SQL compilation
dbt compile --project-dir .

# Check specific model
dbt run --models staging --debug
```

**Materials:**
- Slides 46-65
- dbt profiles.yml template
- Complete dbt models for reference
- dbt commands cheat sheet

---

#### Session 1.4: Dashboard Creation (45 minutes)

**Learning Objectives:**
- Set up Metabase
- Create questions (SQL queries)
- Build dashboard layouts
- Configure automated reports

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review previous session |
| 5-10 min | Metabase Setup | Live demo |
| 10-20 min | Creating Questions | Live coding + student practice |
| 20-30 min | Dashboard Layout | Design activity |
| 30-35 min | Configuration & Formatting | Demonstration |
| 35-40 min | Automated Reports | Demonstration |
| 40-45 min | Q&A | Open discussion |

**Key Teaching Points:**
- Metabase = open-source BI platform
- Questions = saved SQL queries
- Dashboards = organized questions
- Pulses = automated email reports
- Performance matters

**Dashboard Design Principles:**
1. One message per chart
2. Use color intentionally
3. Label everything
4. Keep it simple
5. Highlight insights
6. Consistent formatting

**Class Activity: Dashboard Design**
1. Give students the KPI data
2. Ask them to design a dashboard layout
3. Have them create questions for each KPI
4. Discuss their design choices
5. Compare with the course dashboard

**Common Pitfalls:**
- Metabase connection issues
- Slow dashboard performance
- Confusing visualizations
- Missing key metrics

**Troubleshooting Tips:**
```bash
# Check Metabase
curl http://localhost:3000/api/health

# Check database connection
docker-compose exec postgres pg_isready

# Check logs
docker-compose logs metabase
```

**Materials:**
- Slides 66-85
- Metabase setup guide
- Dashboard layout template
- Sample question SQL

---

### Module 6.2: Analytics Storytelling

#### Session 2.1: The Art of Storytelling (30 minutes)

**Learning Objectives:**
- Understand the SCR framework
- Recognize the importance of storytelling
- Apply the 5-Minute Rule

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | The Data-to-Decision Gap | Discussion |
| 10-20 min | SCR Framework | Live examples |
| 20-25 min | 5-Minute Rule | Practice exercise |
| 25-30 min | Q&A | Open discussion |

**Key Teaching Points:**
- Data insights are valuable only if they drive decisions
- Stories are more memorable than data
- SCR = Situation, Complication, Resolution
- 5-Minute Rule: core message understood in 5 minutes

**SCR Examples:**

| Situation | Complication | Resolution |
|-----------|--------------|------------|
| "We have 4,258 customers" | "Churn is 52% above industry average" | "Implement retention program" |
| "Revenue is $1.2M/month" | "Growth has slowed to 2%" | "Launch upsell campaign" |
| "Customer satisfaction is high" | "But engagement is dropping" | "Improve onboarding" |

**Class Exercise: SCR Practice**
1. Give students a business scenario
2. Ask them to identify S, C, and R
3. Have them write a 30-second pitch
4. Share with the class

**Common Pitfalls:**
- Students bury the lead
- Too much detail, not enough narrative
- Forgetting the "what's at stake"
- No clear call to action

**Materials:**
- Slides 86-95
- SCR framework template
- Business scenarios for practice

---

#### Session 2.2: Understanding Your Audience (30 minutes)

**Learning Objectives:**
- Identify executive personas
- Tailor communication to each persona
- Build credibility with stakeholders

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Executive Personas | Instructor presentation |
| 10-15 min | Persona Analysis | Group activity |
| 15-20 min | Communication Principles | Instructor presentation |
| 20-25 min | Case Study | Group discussion |
| 25-30 min | Q&A | Open discussion |

**Key Teaching Points:**
- Different executives need different messages
- CEO = big picture, CFO = financials, CMO = customers, CTO = tech
- Tailor your communication accordingly
- Credibility comes from preparation

**Executive Personas Table:**

| Persona | Focus | Pain Point | Style |
|---------|-------|------------|-------|
| Visionary CEO | Long-term growth | Too much detail | Big picture |
| Operational CFO | Cost efficiency | Vague ROI | Financial |
| Customer-Focused CMO | Customer acquisition | Not connecting | Customer |
| Technical CTO | Technical excellence | No business context | Tech + business |

**Communication Principles:**
- Start with the bottom line
- Use concrete numbers
- Connect to business outcomes
- Be specific about recommendations
- Show clear action steps

**Class Activity: Persona Analysis**
1. Divide students into groups
2. Assign each group a persona
3. Give them a scenario (churn analysis)
4. Ask them to prepare a 2-minute pitch for their persona
5. Present to the class

**Common Pitfalls:**
- Using technical jargon with non-technical audience
- Providing too many options
- Forgetting the "ask"
- Not understanding the audience's priorities

**Materials:**
- Slides 96-105
- Executive persona cards
- Scenario worksheets

---

#### Session 2.3: Translating Statistics (30 minutes)

**Learning Objectives:**
- Translate statistical concepts into business language
- Answer the "So What" test
- Build trust through clear communication

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Statistical Translation | Instructor presentation |
| 10-15 min | Translation Practice | Individual exercise |
| 15-20 min | Common Mistakes | Discussion |
| 20-25 min | The "So What" Test | Practice |
| 25-30 min | Q&A | Open discussion |

**Key Teaching Points:**
- Your job is to translate statistical complexity
- Every number should answer "So what?"
- P-value = confidence level
- R-squared = variance explained
- Confidence interval = likely range

**Translation Examples:**

| Statistical | Business |
|-------------|----------|
| p-value = 0.03 | "We're 97% certain this is real" |
| R² = 0.85 | "Explains 85% of what we're predicting" |
| 95% CI [82.50, 88.30] | "We're 95% sure it's between $82.50 and $88.30" |
| AUC-ROC = 0.92 | "We correctly distinguish 92% of the time" |

**Class Exercise: Translation Practice**
1. Give students statistical statements
2. Ask them to translate to business language
3. Share translations with the class
4. Discuss which translations are most effective

**Common Pitfalls:**
- Failing to translate technical terms
- Over-explaining methodology
- Not providing business context
- Using "the data shows" instead of "we recommend"

**Materials:**
- Slides 106-120
- Statistical translation cards
- Practice worksheet

---

#### Session 2.4: Executive Summaries & Presentations (30 minutes)

**Learning Objectives:**
- Write effective executive summaries
- Design compelling presentations
- Prepare for Q&A sessions

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Executive Summary Structure | Instructor presentation |
| 10-15 min | Sample Review | Group critique |
| 15-20 min | Presentation Design | Instructor presentation |
| 20-25 min | Q&A Preparation | Discussion |
| 25-30 min | Wrap-up | Final Q&A |

**Key Teaching Points:**
- Executive summary = strategic document, not technical report
- One-page rule: if it doesn't fit on one page, it's too long
- Bottom line first
- Be specific about recommendations
- Every presentation needs a call to action

**Executive Summary Structure:**
1. The Situation (where we are)
2. The Complication (what changed)
3. The Resolution (what to do)
4. Implementation (how to do it)
5. Decision Required (what we need)

**Presentation Design Principles:**
- One idea per slide
- Less text, more visuals
- Clear hierarchy
- 30+ point font

**Class Activity: Executive Summary Writing**
1. Give students the churn scenario
2. Ask them to write a one-page executive summary
3. Have them swap and critique each other's summaries
4. Discuss what makes a summary effective

**Common Pitfalls:**
- Making it too long
- Hiding the conclusion
- Not being specific enough
- Forgetting the "ask"
- Not considering the audience

**Materials:**
- Slides 121-145
- Executive summary template
- Sample executive summaries (good and bad)
- Presentation design guidelines

---

### Module 6.3: Data Ethics & Governance

#### Session 3.1: Introduction to AI Ethics (30 minutes)

**Learning Objectives:**
- Understand why AI ethics matters
- Identify key ethical concepts
- Recognize real-world AI failures

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Why Ethics Matters | Discussion |
| 10-15 min | Key Ethical Concepts | Instructor presentation |
| 15-20 min | Real-World Failures | Case study discussion |
| 20-25 min | Regulatory Landscape | Instructor presentation |
| 25-30 min | Q&A | Open discussion |

**Key Teaching Points:**
- AI makes decisions affecting people's lives
- Bias is real and harmful
- Regulations are increasing (GDPR, CCPA, AI Act)
- Good ethics = Good business

**Real-World AI Failures:**
- Amazon recruitment AI (gender bias)
- COMPAS recidivism (racial bias)
- Google photo labeling (racial bias)
- Apple Card credit (gender bias)

**Ethical Concepts:**
- Fairness: No unjust bias
- Transparency: Understandable decisions
- Accountability: Responsible for outcomes
- Privacy: Protect personal data

**Class Discussion Questions:**
1. "Have you seen bias in AI systems at work?"
2. "What's your organization's approach to AI ethics?"
3. "What are the biggest risks of ignoring ethics?"

**Common Pitfalls:**
- Students think ethics is optional
- Not understanding the business case for ethics
- Confusing legality with ethics

**Materials:**
- Slides 146-155
- AI failure case studies
- Regulatory overview

---

#### Session 3.2: Fairness Analysis (45 minutes)

**Learning Objectives:**
- Define fairness metrics
- Calculate fairness disparities
- Apply mitigation techniques

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Fairness Definitions | Instructor presentation |
| 10-20 min | Calculating Fairness Metrics | Live coding |
| 20-30 min | Interpreting Results | Group analysis |
| 30-40 min | Mitigation Techniques | Live coding |
| 40-45 min | Q&A | Open discussion |

**Key Teaching Points:**
- Demographic parity = equal selection rates
- Equalized odds = equal error rates
- Equal opportunity = equal true positive rates
- Individual fairness = similar individuals, similar outcomes

**Fairness Metrics:**

| Metric | What It Measures | Acceptable |
|--------|------------------|------------|
| Demographic Parity | Selection rates across groups | < 0.10 |
| Equalized Odds | Error rates across groups | < 0.10 |
| Disparate Impact | Selection rate ratio | > 0.80 |

**Mitigation Techniques:**
- Pre-processing: Reweight data
- In-processing: Fairness constraints
- Post-processing: Adjust thresholds

**Class Activity: Fairness Analysis**
1. Give students model predictions and protected groups
2. Ask them to calculate fairness metrics
3. Have them interpret the results
4. Discuss mitigation strategies

**Common Pitfalls:**
- Not understanding what protected attributes to use
- Confusing different fairness metrics
- Thinking fairness is binary (it's contextual)
- Not considering the business trade-offs

**Materials:**
- Slides 156-170
- Fairlearn code examples
- Fairness calculation worksheet

---

#### Session 3.3: Model Explainability (45 minutes)

**Learning Objectives:**
- Implement SHAP explanations
- Interpret SHAP visualizations
- Generate explainability reports

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Why Explainability Matters | Discussion |
| 10-15 min | SHAP Overview | Instructor presentation |
| 15-25 min | SHAP Implementation | Live coding |
| 25-35 min | Interpreting SHAP | Analysis exercise |
| 35-40 min | Explainability Reports | Demonstration |
| 40-45 min | Q&A | Open discussion |

**Key Teaching Points:**
- SHAP = SHapley Additive exPlanations
- Based on game theory
- Consistent and model-agnostic
- Positive SHAP = increases prediction
- Negative SHAP = decreases prediction

**SHAP Plot Types:**

| Plot | Purpose |
|------|---------|
| Summary | Overall feature importance |
| Bar | Mean |SHAP| values |
| Waterfall | Single prediction explanation |

**Class Activity: SHAP Analysis**
1. Give students a trained model
2. Ask them to generate SHAP values
3. Have them interpret the summary plot
4. Discuss key insights for the business

**Common Pitfalls:**
- Using too large a sample (slows down SHAP)
- Not understanding feature direction
- Confusing SHAP with model coefficients
- Not connecting explanations to business insights

**Materials:**
- Slides 171-185
- SHAP code examples
- SHAP interpretation guide

---

#### Session 3.4: Privacy & Governance (30 minutes)

**Learning Objectives:**
- Implement privacy-preserving techniques
- Understand GDPR/CCPA requirements
- Build a governance framework

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Recap & Objectives | Review |
| 5-10 min | Privacy Concepts | Instructor presentation |
| 10-15 min | Privacy Implementation | Live demo |
| 15-20 min | GDPR/CCPA Overview | Discussion |
| 20-25 min | Governance Framework | Instructor presentation |
| 25-30 min | Q&A | Open discussion |

**Key Teaching Points:**
- Anonymization = remove identifying info
- Pseudonymization = replace with tokens
- Differential Privacy = add noise
- GDPR requires 72-hour breach notification
- Governance is about people, process, and technology

**Privacy Techniques:**
| Technique | Description | Use Case |
|-----------|-------------|----------|
| Anonymization | Remove PII | Public data |
| Pseudonymization | Token replacement | Analytics |
| Differential Privacy | Add noise | Sensitive data |
| Masking | Hide parts | Display |

**Class Discussion Questions:**
1. "How does your organization handle PII?"
2. "What are your biggest privacy challenges?"
3. "How would you prepare for a data breach?"

**Materials:**
- Slides 186-205
- Privacy implementation code
- GDPR/CCPA checklist

---

### Capstone: Executive Decision Pack (5 hours)

#### Session C.1: Integration & Generation (60 minutes)

**Learning Objectives:**
- Integrate all three modules
- Generate the Executive Decision Pack
- Verify all components are correct

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-5 min | Capstone Overview | Instructor presentation |
| 5-10 min | Review All Modules | Quick recap |
| 10-20 min | Capstone Generation | Live demo |
| 20-40 min | Student Generation | Student practice |
| 40-50 min | Integration Check | Group review |
| 50-60 min | Troubleshooting | Q&A |

**Key Teaching Points:**
- Capstone integrates everything learned
- Executive Decision Pack = 6 components
- Automation saves time
- Manual polish adds professionalism

**Capstone Components:**
1. Live BI Dashboard (Module 6.1)
2. Explainability Report (Module 6.3)
3. Fairness Audit (Module 6.3)
4. Executive Summary (Module 6.2)
5. Implementation Roadmap
6. Executive Presentation (Module 6.2)

**Student Practice:**
1. Ensure all data is current
2. Run the capstone generator
3. Review all outputs
4. Identify any issues
5. Document fixes

**Common Pitfalls:**
- Data not fresh
- Models not trained
- Missing dependencies
- Outdated dashboards

**Materials:**
- Slides 206-225
- Capstone generation script
- Integration checklist

---

#### Session C.2: Review & Presentation Prep (60 minutes)

**Learning Objectives:**
- Review and polish deliverables
- Prepare for executive presentation
- Practice delivery skills

**Agenda:**

| Time | Topic | Activity |
|------|-------|----------|
| 0-10 min | Deliverable Review | Peer review |
| 10-20 min | Polish & Refine | Student work |
| 20-35 min | Presentation Prep | Instructor guidance |
| 35-50 min | Practice Presentations | Student practice |
| 50-60 min | Feedback & Q&A | Group discussion |

**Key Teaching Points:**
- Review everything for clarity and correctness
- Polish is important for professionalism
- Practice makes perfect
- Anticipate questions

**Review Checklist:**
- [ ] Numbers are correct
- [ ] Visualizations are clear
- [ ] Recommendations are specific
- [ ] Timeline is realistic
- [ ] Language is professional

**Student Activity: Mock Presentation**
1. Each student presents to the class
2. 5 minutes per presentation
3. Peers provide feedback
4. Instructor provides guidance

**Common Pitfalls:**
- Nervousness during presentations
- Not knowing the material well enough
- Being too technical
- Not having backup slides

**Materials:**
- Slides 226-250
- Presentation feedback form
- Presenter checklist

---

## PART 3: TEACHING TIPS

### Active Learning Techniques

| Technique | Description | When to Use |
|-----------|-------------|-------------|
| **Think-Pair-Share** | Think individually, discuss in pairs, share with class | New concepts |
| **Live Coding** | Code in front of students | Practical skills |
| **Group Activities** | Collaborative problem-solving | Complex concepts |
| **Case Studies** | Real-world applications | Applying skills |
| **Peer Review** | Students critique each other's work | Refining work |
| **Role Play** | Act out scenarios | Communication skills |

### Classroom Management

**Before Class:**
- Send materials 24 hours in advance
- Test all technology (Docker, Metabase, etc.)
- Have backup plans for technical issues
- Prepare extra examples

**During Class:**
- Start with objectives
- Use the "I do, We do, You do" pattern
- Check for understanding frequently
- Use the parking lot for off-topic questions
- Keep to the schedule

**After Class:**
- Send recordings and materials
- Provide office hours for questions
- Collect feedback
- Update materials for the next class

### Engaging Different Learning Styles

| Learning Style | Teaching Approach |
|----------------|-------------------|
| **Visual** | Diagrams, charts, visualizations |
| **Auditory** | Explanations, discussions, podcasts |
| **Kinesthetic** | Hands-on labs, coding exercises |
| **Reading/Writing** | Documentation, notes, templates |

---

## PART 4: COMMON PITFALLS & SOLUTIONS

### Technical Issues

| Issue | Solution | Prevention |
|-------|----------|------------|
| Docker won't start | Check Docker version, restart Docker | Have a backup VM |
| dbt connection fails | Check profiles.yml, verify credentials | Test before class |
| Metabase not syncing | Check database connection, restart | Sync before class |
| Port conflicts | Check for running services | Document port usage |

### Student Issues

| Issue | Solution | Prevention |
|-------|----------|------------|
| Falling behind | Pair with faster student, extra office hours | Check understanding frequently |
| Technical difficulties | Screen share, offer alternative approaches | Provide multiple solutions |
| Lack of motivation | Connect to real-world impact, show examples | Clear objectives, relevance |
| Knowledge gaps | Point to primers, suggest catch-up sessions | Assess prerequisites |

### Timing Issues

| Issue | Solution | Prevention |
|-------|----------|------------|
| Running short | Add more examples, deeper discussion | Have backup material |
| Running long | Skip less critical sections, move to labs | Have a "can skip" list |
| Lab taking too long | Help students individually, provide solutions | Prepare students before lab |

---

## PART 5: DISCUSSION QUESTIONS

### Module 6.1 Discussion Questions

1. "Why do organizations struggle with inconsistent metrics?"
2. "What's the difference between a semantic layer and a data warehouse?"
3. "How does dbt change the way we think about ETL?"
4. "What makes a dashboard effective for executives?"
5. "How do you balance performance with flexibility in dashboards?"

### Module 6.2 Discussion Questions

1. "Why do data-driven decisions often fail without good communication?"
2. "How do you handle disagreement with executive decisions?"
3. "What makes a data visualization compelling?"
4. "How do you build trust with executive stakeholders?"
5. "What's the most challenging part of presenting to executives?"

### Module 6.3 Discussion Questions

1. "How do you balance fairness with model accuracy?"
2. "What are the risks of not explaining model decisions?"
3. "How does GDPR impact everyday data work?"
4. "What's your experience with algorithmic bias?"
5. "How do you build a culture of responsible AI?"

### Capstone Discussion Questions

1. "What was the most challenging part of the capstone?"
2. "How would you present your Executive Decision Pack to a CEO?"
3. "What would you do differently in a real-world implementation?"
4. "How does the Executive Decision Pack compare to your current work?"
5. "What are the next steps after delivering the pack?"

---

## PART 6: GROUP ACTIVITIES

### Activity 1: Semantic Layer Design

**Time:** 30 minutes
**Groups:** 3-4 students
**Objective:** Design a semantic layer for a business scenario

**Instructions:**
1. Choose a business domain (e.g., retail, SaaS, healthcare)
2. Define 3-5 key business metrics
3. Identify the data needed
4. Design the dbt structure (staging → intermediate → mart)
5. Present to the class

**Materials:**
- Whiteboard or digital drawing tool
- Business scenarios
- dbt architecture template

### Activity 2: SCR Storytelling

**Time:** 30 minutes
**Groups:** 2-3 students
**Objective:** Create an SCR story from analysis

**Instructions:**
1. Review the provided data analysis
2. Identify the Situation, Complication, and Resolution
3. Write a 2-minute story
4. Present to the class
5. Get feedback

**Materials:**
- Data analysis report
- SCR template
- Presentation guidelines

### Activity 3: Fairness Audit

**Time:** 45 minutes
**Groups:** 2-3 students
**Objective:** Audit a model for fairness

**Instructions:**
1. Run the provided model
2. Calculate fairness metrics
3. Identify any disparities
4. Recommend mitigation strategies
5. Present findings to the class

**Materials:**
- Trained model
- Fairness evaluation code
- Audit report template

### Activity 4: Executive Presentation

**Time:** 45 minutes
**Groups:** Individual or pairs
**Objective:** Deliver an executive presentation

**Instructions:**
1. Use your Executive Decision Pack
2. Prepare a 10-minute presentation
3. Present to a mock executive audience
4. Answer questions
5. Receive feedback

**Materials:**
- Executive Decision Pack
- Presentation template
- Evaluation rubric

---

## PART 7: ASSESSMENT GUIDE

### Grading Breakdown

| Component | Weight | Type |
|-----------|--------|------|
| Module Quizzes | 20% | Individual |
| Module Labs | 30% | Individual |
| Module Exams | 30% | Individual |
| Capstone Project | 20% | Individual |

### Rubrics

**Rubric 1: Executive Summary (100 points)**

| Criteria | Excellent (90-100) | Good (80-89) | Adequate (70-79) | Needs Improvement (<70) |
|----------|-------------------|--------------|------------------|-------------------------|
| Structure | Perfect SCR flow | Good SCR flow | Some structure | Disorganized |
| Clarity | Crystal clear | Mostly clear | Somewhat clear | Confusing |
| Specificity | Very specific | Mostly specific | Some specifics | Vague |
| Actionability | Clear call to action | Good call to action | Vague call to action | No call to action |
| Professionalism | Polished | Professional | Acceptable | Unprofessional |

**Rubric 2: Dashboard (100 points)**

| Criteria | Excellent (90-100) | Good (80-89) | Adequate (70-79) | Needs Improvement (<70) |
|----------|-------------------|--------------|------------------|-------------------------|
| Design | Beautiful, clear | Good design | Functional | Poor design |
| Performance | < 3 seconds | < 5 seconds | < 10 seconds | > 10 seconds |
| Relevance | All relevant | Mostly relevant | Some relevant | Not relevant |
| Interactivity | Excellent | Good | Basic | None |
| Accuracy | Completely accurate | Mostly accurate | Some errors | Many errors |

**Rubric 3: Explainability Report (100 points)**

| Criteria | Excellent (90-100) | Good (80-89) | Adequate (70-79) | Needs Improvement (<70) |
|----------|-------------------|--------------|------------------|-------------------------|
| Completeness | All sections | Most sections | Some sections | Missing |
| Accuracy | Completely accurate | Mostly accurate | Some errors | Many errors |
| Clarity | Crystal clear | Mostly clear | Somewhat clear | Confusing |
| Business Context | Excellent | Good | Some | None |
| Actionability | Very actionable | Good | Some | None |

---

## PART 8: COURSE MODIFICATIONS

### For Corporate Training

| Modification | Reason | Implementation |
|--------------|--------|----------------|
| Use company data | Relevance | Replace sample data |
| Focus on relevant modules | Time constraints | Skip less relevant content |
| Add case studies | Context | Use company examples |
| Shorter sessions | Work schedules | Split into half-day sessions |
| More hands-on | Learning transfer | Add more labs |

### For Academic Settings

| Modification | Reason | Implementation |
|--------------|--------|----------------|
| More theory | Academic requirements | Add background lectures |
| Research papers | Academic rigor | Add literature review |
| Exams | Grading requirements | Add more assessment |
| Group projects | Collaboration | Add semester project |
| Office hours | Student support | Add TA sessions |

### For Self-Paced Learning

| Modification | Reason | Implementation |
|--------------|--------|----------------|
| More detailed explanations | No instructor | Add more text |
| Self-check questions | No feedback | Add exercises |
| Video recordings | No live sessions | Add recordings |
| Community forum | No peers | Add discussion board |
| Extended timeline | Busy schedule | Add flexibility |

---

## PART 9: TROUBLESHOOTING GUIDE

### Docker Issues

**Issue: Docker won't start**
- **Check:** Docker version, system resources
- **Solution:** Restart Docker, increase memory limit
- **Workaround:** Use local PostgreSQL installation

**Issue: Port conflict**
- **Check:** `lsof -i :5432`, `lsof -i :3000`
- **Solution:** Change port mapping in docker-compose.yml
- **Workaround:** Stop conflicting service

**Issue: Mounted volume issues**
- **Check:** File permissions, path correctness
- **Solution:** `chmod -R 755 ./data`
- **Workaround:** Use local file copying

### dbt Issues

**Issue: Connection failed**
- **Check:** profiles.yml, database status
- **Solution:** Update profiles.yml, restart database
- **Workaround:** Use local duckDB instead

**Issue: Model errors**
- **Check:** SQL syntax, column names
- **Solution:** Fix SQL, use `dbt compile` to debug
- **Workaround:** Run SQL directly in database

**Issue: Materialization issues**
- **Check:** `dbt_project.yml` config
- **Solution:** Update materialization setting
- **Workaround:** Use `--full-refresh`

### Metabase Issues

**Issue: Won't start**
- **Check:** docker-compose logs metabase
- **Solution:** Restart, check database connection
- **Workaround:** Use cloud version

**Issue: Sync failing**
- **Check:** Database connection, permissions
- **Solution:** Check credentials, run sync manually
- **Workaround:** Use native queries

**Issue: Dashboard slow**
- **Check:** Query performance, data volume
- **Solution:** Add indexes, use materialized views
- **Workaround:** Pre-aggregate data

### Student Technology Issues

**Issue: Python version mismatch**
- **Solution:** Use pyenv, conda, or Docker
- **Prevention:** Specify Python version in requirements

**Issue: Environment variables**
- **Solution:** Check .env file, verify settings
- **Prevention:** Provide .env.example

**Issue: Library conflicts**
- **Solution:** Use virtual environment
- **Prevention:** Provide requirements.txt

---

## PART 10: FEEDBACK FORMS

### Student Feedback Form

```markdown
# Executive Decision Pipeline: Student Feedback

## Course Overview
- **Course Name:** _________________________________
- **Instructor:** _________________________________
- **Date:** _________________________________
- **Module:** _________________________________

## Overall Ratings
| Aspect | Poor | Fair | Good | Excellent |
|--------|------|------|------|-----------|
| Content Quality | [ ] | [ ] | [ ] | [ ] |
| Instructor Knowledge | [ ] | [ ] | [ ] | [ ] |
| Practical Exercises | [ ] | [ ] | [ ] | [ ] |
| Materials Quality | [ ] | [ ] | [ ] | [ ] |
| Overall Value | [ ] | [ ] | [ ] | [ ] |

## Learning Effectiveness
1. **What was the most valuable part of the course?**
   _________________________________________________
   _________________________________________________

2. **What was the least valuable part?**
   _________________________________________________
   _________________________________________________

3. **What would you change?**
   _________________________________________________
   _________________________________________________

4. **What did you learn?**
   _________________________________________________
   _________________________________________________

5. **How will you apply this?**
   _________________________________________________
   _________________________________________________

## Instructor Feedback
1. **What did the instructor do well?**
   _________________________________________________

2. **What could the instructor improve?**
   _________________________________________________

3. **Was the pace appropriate?**
   [ ] Too fast [ ] Good [ ] Too slow

## Logistics
1. **Was the location/setup suitable?**
   [ ] Yes [ ] No - Please explain: _________________________________

2. **Were the materials accessible?**
   [ ] Yes [ ] No - Please explain: _________________________________

3. **Any technical issues?**
   _________________________________________________

## Additional Comments
_________________________________________________
_________________________________________________
_________________________________________________
```

### Instructor Self-Evaluation

```markdown
# Executive Decision Pipeline: Instructor Self-Evaluation

## Session Information
- **Date:** _________________________________
- **Module:** _________________________________
- **Topic:** _________________________________

## Teaching Effectiveness
| Aspect | Poor | Fair | Good | Excellent |
|--------|------|------|------|-----------|
| Preparation | [ ] | [ ] | [ ] | [ ] |
| Clarity | [ ] | [ ] | [ ] | [ ] |
| Engagement | [ ] | [ ] | [ ] | [ ] |
| Pacing | [ ] | [ ] | [ ] | [ ] |
| Examples | [ ] | [ ] | [ ] | [ ] |
| Q&A Handling | [ ] | [ ] | [ ] | [ ] |

## What Went Well
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

## What Could Be Improved
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

## Student Engagement
- **Number of students:** _____
- **Engagement level:** [ ] High [ ] Medium [ ] Low
- **Most engaged topic:** _________________________________
- **Least engaged topic:** _________________________________

## Notes for Next Time
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

## Additional Resources Needed
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
```

---

## PART 11: COURSE PREPARATION CHECKLIST

### Before Course Start

#### Week Before
- [ ] Review all materials
- [ ] Test all code examples
- [ ] Verify Docker setup
- [ ] Check all URLs
- [ ] Prepare slides
- [ ] Set up virtual environment
- [ ] Create student accounts (if needed)

#### Day Before
- [ ] Send welcome email
- [ ] Post materials
- [ ] Test technology
- [ ] Set up room/environment
- [ ] Print handouts
- [ ] Prepare backup materials

#### Day Of
- [ ] Arrive 30 minutes early
- [ ] Test all technology
- [ ] Check room setup
- [ ] Verify network
- [ ] Have emergency contacts
- [ ] Take attendance

### After Course End

#### Immediate
- [ ] Collect feedback
- [ ] Answer remaining questions
- [ ] Share materials
- [ ] Send certificates

#### Follow-up
- [ ] Review feedback
- [ ] Update materials
- [ ] Plan improvements
- [ ] Schedule follow-up (if needed)

---

## PART 12: ADDITIONAL RESOURCES

### Instructor Resources

| Resource | Description | Link |
|----------|-------------|------|
| dbt Certification | Official dbt training | https://www.getdbt.com/certification |
| Metabase Training | Official Metabase resources | https://www.metabase.com/learn |
| SHAP Documentation | Complete SHAP guide | https://shap.readthedocs.io/ |
| Fairlearn Documentation | Fairness toolkit | https://fairlearn.org/ |
| AI Ethics Resources | Comprehensive ethics guide | https://aiethics.org/ |

### Reference Materials

| Material | Description |
|----------|-------------|
| Executive Decision Pipeline: Complete Slide Deck | All course slides |
| Student Workbook | All exercises |
| Student Notes | Lecture summaries |
| Quiz & Test Bank | Assessment package |
| References & Resources Guide | Continued learning |
| Trainer Guide | This document |

---

## FINAL NOTES

### Teaching Philosophy

The Executive Decision Pipeline course is designed to be:

1. **Practical** - Everything is hands-on and applicable
2. **Comprehensive** - Covers engineering, communication, and ethics
3. **Scalable** - Works for self-paced, corporate, and academic settings
4. **Current** - Uses modern tools and techniques
5. **Responsible** - Emphasizes ethics and explainability

### Continuous Improvement

- **Update materials** - Keep current with new tools
- **Add new examples** - From real-world practice
- **Refine exercises** - Based on student feedback
- **Expand content** - Add advanced topics
- **Build community** - Connect students and alumni

### Final Thoughts

> "Data is just data. It's what you do with it that matters. This course equips students to bridge the gap between data engineering and executive decision-making."

*This Trainer Guide provides everything you need to deliver the Executive Decision Pipeline course effectively. Adapt it to your audience and teaching style.*
