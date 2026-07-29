# Trainer Guide: MLOps Pipeline Engineering

## Comprehensive Instructor Manual for Teaching the Series

---

# TABLE OF CONTENTS

**Section 1: Course Overview**
- 1.1 Course Description
- 1.2 Learning Objectives
- 1.3 Target Audience
- 1.4 Prerequisites
- 1.5 Course Structure
- 1.6 Schedule and Timeline

**Section 2: Preparation**
- 2.1 Instructor Preparation
- 2.2 Environment Setup
- 2.3 Materials Checklist
- 2.4 Student Readiness
- 2.5 Classroom Setup

**Section 3: Teaching Strategy**
- 3.1 Pedagogical Approach
- 3.2 Session Structure
- 3.3 Timing Guidelines
- 3.4 Common Challenges
- 3.5 Success Metrics

**Section 4: Module Guides**
- 4.1 Module 0: Introduction
- 4.2 Phase 1: DVC (Parts 1-4)
- 4.3 Phase 2: MLflow (Parts 5-8)
- 4.4 Phase 3: Dagster (Parts 9-12)
- 4.5 Phase 4: Integration (Parts 13-15)

**Section 5: Activities and Exercises**
- 5.1 Lab Exercises
- 5.2 Group Activities
- 5.3 Discussion Questions
- 5.4 Assessment Guide

**Section 6: Troubleshooting Guide**
- 6.1 Technical Issues
- 6.2 Student Issues
- 6.3 Tool Issues
- 6.4 Environment Issues

**Section 7: Assessment and Grading**
- 7.1 Quizzes and Tests
- 7.2 Lab Assignments
- 7.3 Final Project
- 7.4 Grading Rubric

**Section 8: Additional Resources**
- 8.1 Trainer Resources
- 8.2 Student Resources
- 8.3 Further Reading

---

# SECTION 1: COURSE OVERVIEW

## 1.1 Course Description

### Course Title
**MLOps Pipeline Engineering: From Development to Production**

### Course Synopsis
This comprehensive course bridges the gap between experimental machine learning and production-grade MLOps. Students learn to build reproducible, trackable, and automated end-to-end data and machine learning pipelines using industry-standard tools: DVC, MLflow, and Dagster.

### Key Themes
- Data and artifact versioning with DVC
- Experiment tracking and model registry with MLflow
- Pipeline orchestration with Dagster
- End-to-end integration and deployment
- Production monitoring and alerting

### Course Format
- **Duration:** 8 weeks (full-time) or 16 weeks (part-time)
- **Delivery:** In-person or remote
- **Method:** Lecture + Hands-on Labs
- **Prerequisites:** Python, Git, basic ML concepts

---

## 1.2 Learning Objectives

### By the end of this course, students will be able to:

**Phase 1: Data Versioning (DVC)**
- Set up DVC with Git for comprehensive workspace tracking
- Version large datasets, feature stores, and model artifacts
- Configure and secure remote storage backends
- Build and manage data pipelines with DVC
- Implement data reproducibility and versioning workflows

**Phase 2: Experiment Tracking (MLflow)**
- Set up MLflow tracking server and client
- Log training runs, parameters, metrics, and artifacts
- Manage model registry across operational states
- Compare experiments and visualize results
- Package models for reliable downstream inference

**Phase 3: Pipeline Orchestration (Dagster)**
- Build production-grade DAGs with Dagster
- Define task dependencies and custom operators
- Implement sensors and schedules for automation
- Handle errors and retries gracefully
- Develop reusable pipeline components

**Phase 4: Full Integration**
- Orchestrate the complete ML lifecycle
- Implement CI/CD for ML pipelines
- Build monitoring and alerting systems
- Deploy models to production
- Apply MLOps best practices

---

## 1.3 Target Audience

### Primary Audience
- Data Scientists transitioning to production
- ML Engineers building production systems
- Software Engineers entering ML
- DevOps Engineers building ML infrastructure

### Secondary Audience
- Data Analysts interested in automation
- Product Managers of ML products
- Technical leads managing ML teams
- Students in data science programs

### Student Profile
- **Experience:** 1-5 years in data/software
- **Python Skills:** Intermediate (functions, classes)
- **Git Skills:** Basic (commits, branches)
- **ML Knowledge:** Basic concepts (training, validation)
- **Cloud Awareness:** Basic understanding

---

## 1.4 Prerequisites

### Required Skills
- **Python:** Functions, classes, modules, error handling
- **Git:** Commits, branches, remotes, basic workflow
- **Command Line:** Navigation, running scripts, environment variables
- **ML Concepts:** Understanding of training, validation, features, labels

### Recommended Experience
- **Data Analysis:** Pandas, NumPy experience
- **ML Frameworks:** Scikit-learn, PyTorch, or TensorFlow
- **Cloud Platforms:** AWS, GCP, or Azure basics
- **Docker:** Basic container concepts

### System Requirements
- **Hardware:** 8GB+ RAM, 4+ cores, 50GB+ storage
- **OS:** Linux, macOS, or Windows 10+
- **Software:** Python 3.9+, Git, Docker (optional)
- **Internet:** Broadband for downloads and cloud services

---

## 1.5 Course Structure

### Module Breakdown

| Module | Topic | Duration | Weight |
|--------|-------|----------|--------|
| 0 | Introduction | 1 hour | 5% |
| 1-4 | DVC (Data Versioning) | 2 weeks | 25% |
| 5-8 | MLflow (Experiment Tracking) | 2 weeks | 25% |
| 9-12 | Dagster (Orchestration) | 2 weeks | 25% |
| 13-15 | Integration & Deployment | 1.5 weeks | 20% |
| | **Total** | **8 weeks** | **100%** |

### Part Breakdown

| Phase | Parts | Topics |
|-------|-------|--------|
| Phase 1 | 1-4 | DVC Setup, Versioning, Remote Storage, Pipelines |
| Phase 2 | 5-8 | MLflow Setup, Tracking, Visualization, Registry |
| Phase 3 | 9-12 | Dagster Setup, DAGs, Sensors, Integration |
| Phase 4 | 13-15 | End-to-End, Monitoring, CI/CD |

---

## 1.6 Schedule and Timeline

### Full-Time Schedule (8 Weeks)

| Week | Topics | Activities | Deliverables |
|------|--------|------------|--------------|
| 1 | Introduction + DVC 1-2 | Setup, Versioning | Part 1-2 Lab |
| 2 | DVC 3-4 | Remote Storage, Pipelines | Part 3-4 Lab |
| 3 | MLflow 5-6 | Setup, Tracking | Part 5-6 Lab |
| 4 | MLflow 7-8 | Visualization, Registry | Part 7-8 Lab |
| 5 | Dagster 9-10 | Setup, DAGs | Part 9-10 Lab |
| 6 | Dagster 11-12 | Sensors, Integration | Part 11-12 Lab |
| 7 | Integration 13 | End-to-End Pipeline | Part 13 Lab |
| 8 | Integration 14-15 | Monitoring, CI/CD | Final Project |

### Part-Time Schedule (16 Weeks)

| Week | Topics | Activities |
|------|--------|------------|
| 1 | Introduction | Setup |
| 2-3 | DVC 1-2 | Versioning |
| 4-5 | DVC 3-4 | Pipelines |
| 6-7 | MLflow 5-6 | Tracking |
| 8-9 | MLflow 7-8 | Registry |
| 10-11 | Dagster 9-10 | DAGs |
| 12-13 | Dagster 11-12 | Sensors |
| 14 | Integration 13 | End-to-End |
| 15-16 | Integration 14-15 | Deployment |

---

# SECTION 2: PREPARATION

## 2.1 Instructor Preparation

### Before the Course

**2-4 Weeks Before:**
- Review all course materials
- Set up your teaching environment
- Test all code examples
- Prepare virtual environment
- Create cloud accounts (if needed)

**1 Week Before:**
- Send welcome email to students
- Share prerequisites checklist
- Provide setup instructions
- Set up communication channels
- Prepare slides and demos

**Day Before:**
- Test all demos
- Check lab environment
- Prepare backup materials
- Review student questions

### Instructor Resources

**Tools to Install:**
```
# Required
Python 3.10+
Git 2.30+
DVC 2.0+
MLflow 2.0+
Dagster 1.0+
AWS CLI (for cloud demos)

# Optional
Docker Desktop
VS Code with Python extensions
Postman (for API testing)
```

**Cloud Accounts Needed:**
- AWS Free Tier (or GCP/Azure)
- GitHub Account
- (Optional) Slack for class communication

---

## 2.2 Environment Setup

### Instructor Reference Environment

```bash
# Project structure
mlops-training/
├── dvc-demo/          # DVC examples
├── mlflow-demo/       # MLflow examples
├── dagster-demo/      # Dagster examples
├── integration-demo/  # Complete pipeline
├── slides/            # Presentation slides
└── resources/         # Additional materials

# Start fresh each module
# Keep demo repositories clean
```

### Demo Preparation Checklist

**For Each Module:**
- [ ] Clean repository state
- [ ] Pre-run all code examples
- [ ] Have screenshots ready
- [ ] Know common errors
- [ ] Have troubleshooting steps ready

---

## 2.3 Materials Checklist

### Instructor Materials

**Presentations:**
- Main slide deck (320+ slides)
- Module-specific slides
- Architecture diagrams
- Demo scripts

**Handouts:**
- Student workbook
- Quick reference cards
- Command cheat sheets
- Architecture diagrams

**Code Materials:**
- Complete code repository
- Step-by-step examples
- Starter templates
- Completed solutions

### Student Materials

**Required:**
- Course syllabus
- Setup instructions
- Student workbook
- Access to code repository
- Cloud account credentials

**Optional:**
- Quick reference cards
- Troubleshooting guides
- Additional reading list

---

## 2.4 Student Readiness

### Pre-Course Survey

**Send 2 weeks before:**
1. Python experience (1-5)
2. Git experience (1-5)
3. ML experience (1-5)
4. Cloud experience (1-5)
5. Command line comfort (1-5)
6. Operating system
7. Questions/concerns

### Setup Session

**First Day (1 hour):**
1. Install Python and tools
2. Set up virtual environment
3. Configure Git
4. Test DVC installation
5. Test MLflow installation
6. Test Dagster installation
7. Verify cloud access
8. Troubleshoot issues

---

## 2.5 Classroom Setup

### In-Person Setup

**Equipment:**
- Projector or large screen
- Whiteboard or flip chart
- Internet access (WiFi)
- Power outlets
- Audio system (for videos)

**Software:**
- Presentation software
- Code editor (projected)
- Terminal emulator
- Browser (for tools)

**Seating:**
- Groups of 2-3 for labs
- Visible screen from all seats
- Easy access to power

### Remote Setup

**Platform:**
- Zoom/Teams/Meet
- Screen sharing
- Breakout rooms
- Chat/Questions

**Tools:**
- Shared code editor (optional)
- Online whiteboard
- Document sharing
- Recording (optional)

---

# SECTION 3: TEACHING STRATEGY

## 3.1 Pedagogical Approach

### Teaching Philosophy

**Learn by Doing**
- Code-along during lectures
- Lab exercises after each part
- Independent practice
- Real-world examples

**Progressive Complexity**
- Start simple
- Build incrementally
- Reuse previous concepts
- Integrate at the end

**Active Learning**
- Discussion questions
- Pair programming
- Group projects
- Peer review

### Instructional Methods

**Lecture (20%)**
- Core concepts
- Tool architecture
- Design patterns
- Best practices

**Demo (20%)**
- Live coding
- Tool walkthroughs
- Error demonstrations
- Integration examples

**Lab (40%)**
- Hands-on exercises
- Guided practice
- Independent work
- Group collaboration

**Discussion (20%)**
- Q&A sessions
- Problem solving
- Architecture discussions
- Industry insights

---

## 3.2 Session Structure

### Standard Session (2 hours)

| Time | Activity | Description |
|------|----------|-------------|
| 0:00-0:05 | Welcome | Check-in, agenda |
| 0:05-0:25 | Lecture | Core concepts |
| 0:25-0:30 | Demo | Live demonstration |
| 0:30-0:45 | Lecture | Advanced concepts |
| 0:45-1:00 | Demo | Integration demo |
| 1:00-1:45 | Lab | Hands-on exercise |
| 1:45-2:00 | Review | Q&A, recap, next steps |

### Extended Session (3 hours)

| Time | Activity | Description |
|------|----------|-------------|
| 0:00-0:05 | Welcome | Check-in, agenda |
| 0:05-0:35 | Lecture 1 | Concepts |
| 0:35-0:55 | Demo 1 | Tool demonstration |
| 0:55-1:15 | Lecture 2 | Advanced concepts |
| 1:15-1:35 | Demo 2 | Integration |
| 1:35-1:45 | Break | Rest |
| 1:45-2:45 | Lab | Extended exercise |
| 2:45-3:00 | Review | Q&A, recap |

---

## 3.3 Timing Guidelines

### Per Part Breakdown

| Part | Lecture Time | Demo Time | Lab Time |
|------|--------------|-----------|----------|
| 1: DVC Setup | 30 min | 15 min | 45 min |
| 2: Versioning | 30 min | 20 min | 40 min |
| 3: Remote Storage | 25 min | 15 min | 50 min |
| 4: Pipelines | 35 min | 20 min | 35 min |
| 5: MLflow Setup | 30 min | 15 min | 45 min |
| 6: Logging | 30 min | 20 min | 40 min |
| 7: Visualization | 25 min | 15 min | 50 min |
| 8: Registry | 35 min | 20 min | 35 min |
| 9: Dagster Setup | 30 min | 15 min | 45 min |
| 10: DAGs | 35 min | 20 min | 35 min |
| 11: Sensors | 30 min | 15 min | 45 min |
| 12: Integration | 35 min | 20 min | 35 min |
| 13: End-to-End | 30 min | 25 min | 35 min |
| 14: Monitoring | 25 min | 15 min | 50 min |
| 15: CI/CD | 30 min | 20 min | 40 min |

---

## 3.4 Common Challenges

### Technical Challenges

**Challenge: Students struggle with command line**
- Solution: Provide command reference
- Demo each command
- Pair less experienced students
- Provide recorded demos

**Challenge: Cloud account setup issues**
- Solution: Guide step-by-step
- Provide alternatives
- Use local storage options
- Have backup accounts ready

**Challenge: Tool compatibility issues**
- Solution: Use specified versions
- Provide Docker image
- Test environment thoroughly
- Have troubleshooting guide

### Pedagogical Challenges

**Challenge: Varying skill levels**
- Solution: Pair programming
- Provide optional advanced work
- Offer extra help sessions
- Use peer mentoring

**Challenge: Keeping engagement**
- Solution: Interactive demos
- Real-world examples
- Gamification
- Breakout discussions

**Challenge: Covering all material**
- Solution: Prioritize core topics
- Provide self-study materials
- Record sessions
- Offer office hours

---

## 3.5 Success Metrics

### Student Success Indicators

**Immediate Indicators:**
- Lab completion rate
- Quiz scores
- Engagement in class
- Questions asked

**Mid-Course Indicators:**
- Project progress
- Tool proficiency
- Independent work quality
- Peer collaboration

**Final Indicators:**
- Final project quality
- Tool mastery
- System understanding
- Confidence level

### Course Success Metrics

- Student completion rate
- Average quiz scores
- Project success rate
- Student satisfaction
- Career impact
- Skill application

---

# SECTION 4: MODULE GUIDES

## 4.1 Module 0: Introduction

### Learning Objectives

After this module, students will be able to:
- Explain what MLOps is and why it matters
- Describe the MLOps lifecycle
- Identify the three pillars of MLOps
- Set up their development environment
- Understand the course structure and expectations

### Key Concepts

- MLOps definition and value proposition
- ML lifecycle challenges
- DVC, MLflow, Dagster introduction
- Predictive maintenance use case
- Environment setup

### Teaching Points

**Start with "Why"**
- 80% of ML projects fail in production
- Reproducibility crisis in ML
- Cost of poor MLOps

**Use the Analogy**
- ML research = Cooking at home
- ML production = Commercial kitchen
- Tools = Equipment

**Real-World Connection**
- Predictive maintenance case
- Business value of MLOps
- Career opportunities

### Common Questions

**Q: Why not just use Git?**
A: Git cannot handle large files efficiently

**Q: Is MLOps only for large companies?**
A: No, it scales from solo projects to enterprise

**Q: Do I need all three tools?**
A: Yes, they serve complementary purposes

---

## 4.2 Phase 1: DVC (Parts 1-4)

### Part 1: DVC Setup

**Objectives:**
- Install and initialize DVC
- Understand DVC architecture
- Version first data file
- Integrate with Git

**Key Demonstrations:**
1. `dvc init` and directory structure
2. `dvc add` with sample file
3. Git commit of .dvc file
4. `dvc status` command

**Lab Exercise:**
- Initialize DVC in project
- Create and version sample dataset
- Commit to Git
- Verify with `dvc status`

**Common Pitfalls:**
- Forgetting to add .dvc file to Git
- Not understanding cache location
- Versioning files in wrong order

---

### Part 2: Versioning Datasets

**Objectives:**
- Version multiple datasets
- Create feature engineering pipeline
- Version processed data
- Use DVC pipelines

**Key Demonstrations:**
1. Generating synthetic data
2. Feature engineering script
3. DVC pipeline definition
4. `dvc repro` execution

**Lab Exercise:**
- Create sensor data generator
- Build feature script
- Define DVC pipeline
- Run and verify

**Common Pitfalls:**
- Not tracking all dependencies
- Missing parameter changes
- Not using `dvc repro`

---

### Part 3: Remote Storage

**Objectives:**
- Configure AWS S3 remote
- Set up credentials securely
- Push and pull data
- Test collaboration workflow

**Key Demonstrations:**
1. AWS CLI configuration
2. DVC remote add
3. `dvc push` and `dvc pull`
4. Secure credential handling

**Lab Exercise:**
- Create S3 bucket
- Configure DVC remote
- Push data
- Pull on fresh environment

**Common Pitfalls:**
- Incorrect IAM permissions
- Missing credentials
- Wrong remote URL format

---

### Part 4: DVC Pipelines

**Objectives:**
- Build complex pipelines
- Use parameters
- Track metrics
- Compare versions

**Key Demonstrations:**
1. Multi-stage pipeline
2. Parameter usage
3. Metrics tracking
4. Version comparison

**Lab Exercise:**
- Add model training stage
- Add evaluation stage
- Compare versions
- Use dvc metrics

**Common Pitfalls:**
- Overly complex pipelines
- Missing parameter changes
- Not using metrics

---

## 4.3 Phase 2: MLflow (Parts 5-8)

### Part 5: MLflow Setup

**Objectives:**
- Install and configure MLflow
- Understand MLflow architecture
- Set up tracking server
- Create first experiment

**Key Demonstrations:**
1. `mlflow ui` command
2. Tracking URI configuration
3. First experiment run
4. UI exploration

**Lab Exercise:**
- Install MLflow
- Start tracking UI
- Create experiment
- Run first training

**Common Pitfalls:**
- Wrong tracking URI
- Not setting experiment
- Forgetting to start UI

---

### Part 6: Logging Runs

**Objectives:**
- Log parameters and metrics
- Store artifacts
- Use tags
- Compare runs

**Key Demonstrations:**
1. Parameter logging
2. Metric logging
3. Artifact logging
4. Run comparison

**Lab Exercise:**
- Log complete experiment
- Add plots as artifacts
- Log model
- Compare runs

**Common Pitfalls:**
- Missing parameter logging
- Not using tags
- Forgetting artifacts

---

### Part 7: Visualization

**Objectives:**
- Use MLflow UI for comparison
- Create custom visualizations
- Export experiment data
- Build dashboards

**Key Demonstrations:**
1. UI comparison features
2. Parallel coordinates
3. Custom plots
4. Data export

**Lab Exercise:**
- Compare experiments
- Create custom plots
- Export data
- Build simple dashboard

**Common Pitfalls:**
- Not using comparison features
- Missing data in exports
- Overcomplicated dashboards

---

### Part 8: Model Registry

**Objectives:**
- Register models
- Manage stages
- Promote models
- Track lineage

**Key Demonstrations:**
1. Model registration
2. Stage transitions
3. Model promotion
4. Lineage tracking

**Lab Exercise:**
- Register best model
- Transition to Staging
- Promote to Production
- Archive old models

**Common Pitfalls:**
- Not using registry
- Wrong stage transitions
- Missing metadata

---

## 4.4 Phase 3: Dagster (Parts 9-12)

### Part 9: Dagster Setup

**Objectives:**
- Install and configure Dagster
- Understand architecture
- Create first pipeline
- Use UI

**Key Demonstrations:**
1. Installation and workspace
2. First op definition
3. Job composition
4. UI exploration

**Lab Exercise:**
- Install Dagster
- Create hello world pipeline
- Run and verify
- Explore UI

**Common Pitfalls:**
- Missing DAGSTER_HOME
- Wrong workspace config
- Not starting daemon

---

### Part 10: Building DAGs

**Objectives:**
- Build multi-step pipelines
- Handle dependencies
- Use resources
- Manage data

**Key Demonstrations:**
1. Multi-op pipeline
2. Dependency handling
3. Resource usage
4. I/O management

**Lab Exercise:**
- Build data pipeline
- Add dependencies
- Use resources
- Test pipeline

**Common Pitfalls:**
- Circular dependencies
- Missing resources
- Not using I/O managers

---

### Part 11: Sensors and Schedules

**Objectives:**
- Implement schedules
- Create sensors
- Handle errors
- Automate pipelines

**Key Demonstrations:**
1. Schedule definition
2. Sensor creation
3. Error handling
4. Retry policies

**Lab Exercise:**
- Create daily schedule
- Add file sensor
- Add error handling
- Test automation

**Common Pitfalls:**
- Wrong cron syntax
- Sensor missing cursor
- Not handling failures

---

### Part 12: Integration

**Objectives:**
- Integrate DVC with Dagster
- Integrate MLflow with Dagster
- Build complete pipeline
- End-to-end testing

**Key Demonstrations:**
1. DVC resource
2. MLflow resource
3. Complete pipeline
4. Testing

**Lab Exercise:**
- Create DVC integration
- Create MLflow integration
- Build complete pipeline
- Test end-to-end

**Common Pitfalls:**
- Resource configuration
- Integration errors
- Missing dependencies

---

## 4.5 Phase 4: Integration (Parts 13-15)

### Part 13: End-to-End

**Objectives:**
- Build master pipeline
- Complete data to deployment
- Handle edge cases
- Production readiness

**Key Demonstrations:**
1. Master pipeline assembly
2. Complete workflow
3. Edge case handling
4. Testing

**Lab Exercise:**
- Build master pipeline
- Test complete flow
- Handle errors
- Verify outputs

**Common Pitfalls:**
- Missing steps
- Integration errors
- Not testing thoroughly

---

### Part 14: Monitoring

**Objectives:**
- Implement monitoring
- Configure alerts
- Build dashboards
- Handle drift

**Key Demonstrations:**
1. Metrics collection
2. Alert configuration
3. Dashboard creation
4. Drift detection

**Lab Exercise:**
- Set up monitoring
- Configure alerts
- Build dashboard
- Test alerts

**Common Pitfalls:**
- Missing metrics
- Wrong alert thresholds
- Dashboard complexity

---

### Part 15: CI/CD

**Objectives:**
- Implement CI/CD
- Use GitHub Actions
- Automate deployment
- Handle rollbacks

**Key Demonstrations:**
1. CI/CD pipeline
2. GitHub Actions
3. Deployment automation
4. Rollback testing

**Lab Exercise:**
- Create CI/CD pipeline
- Configure GitHub Actions
- Test deployment
- Practice rollback

**Common Pitfalls:**
- CI/CD configuration
- Secret management
- Rollback not working

---

# SECTION 5: ACTIVITIES AND EXERCISES

## 5.1 Lab Exercises

### Lab 1: DVC Setup and Versioning

**Duration:** 1 hour

**Objectives:**
- Initialize DVC in project
- Version sample dataset
- Understand DVC workflow

**Instructions:**
1. Create project directory
2. Initialize Git and DVC
3. Create sample CSV file
4. Add to DVC
5. Commit to Git
6. Check status

**Verification:**
- DVC files exist
- Sample data tracked
- Git commit complete

---

### Lab 2: Feature Pipeline

**Duration:** 1.5 hours

**Objectives:**
- Build feature pipeline
- Version processed data
- Use DVC pipeline

**Instructions:**
1. Create generate script
2. Create feature script
3. Define dvc.yaml
4. Run `dvc repro`
5. Verify outputs
6. Track processed data

**Verification:**
- Pipeline runs
- Features generated
- Data versioned

---

### Lab 3: MLflow Tracking

**Duration:** 1 hour

**Objectives:**
- Set up MLflow
- Log experiment
- View in UI

**Instructions:**
1. Install MLflow
2. Set tracking URI
3. Create training script
4. Log parameters/metrics
5. Start UI
6. View results

**Verification:**
- UI accessible
- Run appears
- Metrics visible

---

### Lab 4: Model Registry

**Duration:** 1 hour

**Objectives:**
- Register models
- Manage stages
- Promote to production

**Instructions:**
1. Train model
2. Register in registry
3. Transition to Staging
4. Validate
5. Promote to Production

**Verification:**
- Model registered
- Stage transitions
- Promotion successful

---

### Lab 5: Dagster Pipeline

**Duration:** 1.5 hours

**Objectives:**
- Build Dagster pipeline
- Run and monitor
- Use UI

**Instructions:**
1. Create pipeline file
2. Define ops
3. Compose job
4. Run with CLI
5. View in UI

**Verification:**
- Pipeline runs
- UI shows job
- Results correct

---

### Lab 6: Complete Pipeline

**Duration:** 2 hours

**Objectives:**
- Build complete pipeline
- Integrate all tools
- Test end-to-end

**Instructions:**
1. Create DVC pipeline
2. Add MLflow tracking
3. Orchestrate with Dagster
4. Run complete flow
5. Verify results

**Verification:**
- All steps run
- Data versioned
- Experiments tracked
- Pipeline successful

---

## 5.2 Group Activities

### Activity 1: Architecture Design

**Duration:** 1 hour

**Description:**
Teams design an MLOps architecture for a given scenario

**Scenario Options:**
1. E-commerce recommendation system
2. Healthcare predictive diagnostics
3. Financial fraud detection
4. Manufacturing quality control

**Deliverable:**
- Architecture diagram
- Tool selection justification
- Data flow description
- Deployment strategy

---

### Activity 2: Tool Comparison

**Duration:** 45 minutes

**Description:**
Compare MLOps tools and make recommendations

**Teams:**
- Team A: DVC vs. other data versioning
- Team B: MLflow vs. other experiment tracking
- Team C: Dagster vs. other orchestration

**Deliverable:**
- Feature comparison matrix
- Use case recommendations
- Pros/cons analysis

---

### Activity 3: Production Readiness Review

**Duration:** 1 hour

**Description:**
Review a system for production readiness

**Review Areas:**
- Data versioning
- Experiment tracking
- Pipeline automation
- Monitoring
- Deployment

**Deliverable:**
- Readiness score
- Improvement recommendations
- Implementation plan

---

## 5.3 Discussion Questions

### Module 0 Discussion

1. Why do you think 80% of ML projects never reach production?
2. How does MLOps differ from traditional DevOps?
3. What are the risks of not using data versioning?
4. How could MLOps benefit your current work?

### Phase 1 Discussion

1. Why is data versioning critical for reproducibility?
2. What are the challenges of versioning large datasets?
3. How does DVC compare to Git LFS?
4. When should you version processed vs. raw data?

### Phase 2 Discussion

1. What's the value of experiment tracking?
2. How does the model registry help with governance?
3. What metrics should you track for each experiment?
4. How do you choose which model to promote?

### Phase 3 Discussion

1. Why is pipeline orchestration important?
2. How does Dagster handle dependencies differently?
3. When should you use schedules vs. sensors?
4. What are the benefits of asset-based workflows?

### Phase 4 Discussion

1. What are the key challenges in MLOps integration?
2. How do you balance automation with control?
3. What metrics are most important for monitoring?
4. How do you handle model drift in production?

---

## 5.4 Assessment Guide

### Quiz Strategy

- 10 questions per quiz
- Mix of multiple choice and true/false
- Cover core concepts
- Include practical scenarios

### Lab Assessment

- Code works correctly
- Follows best practices
- Proper error handling
- Good documentation

### Project Assessment

- Completeness of solution
- Code quality
- Documentation
- Tool integration
- Production readiness

---

# SECTION 6: TROUBLESHOOTING GUIDE

## 6.1 Technical Issues

### Environment Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Python version mismatch | Import errors | Use pyenv or conda |
| Package conflicts | Dependency errors | Use virtual environment |
| Permission denied | Cannot access files | Check file permissions |
| Port in use | Service won't start | Use different port |

### DVC Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Cache corruption | Data won't load | `dvc cache verify` |
| Remote connection | Push/pull fails | Check credentials |
| Pipeline not updating | Status shows unchanged | `dvc repro --force` |
| Large cache | Disk space issues | `dvc gc --workspace` |

### MLflow Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Connection refused | Cannot reach server | Check tracking URI |
| Duplicate runs | Multiple same runs | Use unique names |
| Large artifacts | Upload slow | Use multipart upload |
| Missing artifacts | Cannot find files | Check artifact path |

### Dagster Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Daemon not running | Schedules not triggering | Start `dagster-daemon` |
| Port conflicts | UI won't start | Use different port |
| Resource errors | Ops fail | Check resource config |
| Memory issues | Runs fail | Increase memory limit |

---

## 6.2 Student Issues

### Common Student Challenges

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Lagging behind | Not completing labs | Pair with faster student |
| Confused about concepts | Questions in class | Review fundamentals |
| Tool installation fails | Errors installing | Use Docker image |
| Time management | Behind schedule | Prioritize core topics |

### Helping Struggling Students

**Identify Early:**
- Monitor lab completion
- Watch engagement levels
- Check quiz scores
- Ask open-ended questions

**Interventions:**
- One-on-one help
- Additional resources
- Study groups
- Pair programming

---

## 6.3 Tool Issues

### DVC Troubleshooting

```bash
# Check DVC version
dvc --version

# Verify configuration
dvc config --list

# Debug remote
dvc remote list
dvc remote default

# Check cache
dvc cache dir
du -sh .dvc/cache/

# Verify pipeline
dvc status --checks
dvc dag
```

### MLflow Troubleshooting

```bash
# Check MLflow version
mlflow --version

# Verify tracking URI
python -c "import mlflow; print(mlflow.get_tracking_uri())"

# Test connection
python -c "import mlflow; mlflow.get_experiment_by_name('test')"

# Check UI
mlflow ui --backend-store-uri ./mlruns
```

### Dagster Troubleshooting

```bash
# Check Dagster version
dagster --version

# Verify installation
dagster-webserver --help

# Check daemon
dagster-daemon run

# Debug schedule
dagster schedule list
dagster schedule preview <schedule>
```

---

## 6.4 Environment Issues

### Virtual Environment Problems

```bash
# Recreate environment
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Check environment
which python
pip list | grep dvc
pip list | grep mlflow
pip list | grep dagster
```

### Cloud Account Issues

**AWS Issues:**
```bash
# Check credentials
aws configure list
aws sts get-caller-identity

# Check permissions
aws s3 ls
aws s3 mb s3://test-bucket
```

**GCS Issues:**
```bash
# Check authentication
gcloud auth list
gcloud auth application-default login

# Check bucket access
gsutil ls
gsutil mb gs://test-bucket
```

---

# SECTION 7: ASSESSMENT AND GRADING

## 7.1 Quizzes and Tests

### Quiz Schedule

| Week | Quiz | Topics | Questions |
|------|------|--------|-----------|
| 1 | Quiz 0 | Introduction | 10 |
| 2 | Quiz 1.1 | DVC Basics | 15 |
| 3 | Quiz 1.2 | DVC Pipelines | 15 |
| 4 | Quiz 2.1 | MLflow Basics | 15 |
| 5 | Quiz 2.2 | MLflow Registry | 15 |
| 6 | Quiz 3.1 | Dagster Basics | 15 |
| 7 | Quiz 3.2 | Dagster Advanced | 15 |
| 8 | Quiz 4 | Integration | 15 |

### Grading Breakdown

| Component | Weight | Description |
|-----------|--------|-------------|
| Quizzes | 20% | Weekly quizzes |
| Labs | 30% | Lab assignments |
| Project | 30% | Final project |
| Participation | 10% | Engagement |
| Final Exam | 10% | Comprehensive |

---

## 7.2 Lab Assignments

### Grading Criteria

| Criteria | Weight | Description |
|----------|--------|-------------|
| Correctness | 40% | Code works correctly |
| Quality | 20% | Code quality and style |
| Documentation | 15% | Comments and docs |
| Tool Usage | 15% | Proper tool use |
| Error Handling | 10% | Edge cases covered |

### Sample Lab Rubric

**Lab 4: Model Registry**

| Criteria | Excellent (4) | Good (3) | Satisfactory (2) | Needs Work (1) |
|----------|---------------|----------|------------------|----------------|
| Registration | Complete | Most features | Basic | Missing |
| Stages | All stages | Staging + Prod | Basic | None |
| Promotion | Automated | Manual | Partial | Missing |
| Documentation | Comprehensive | Complete | Basic | Missing |

---

## 7.3 Final Project

### Project Requirements

**Project: End-to-End MLOps Pipeline**

**Description:**
Build a complete MLOps pipeline for a predictive maintenance system.

**Requirements:**
1. DVC: Version data (raw + processed)
2. MLflow: Track experiments (params + metrics)
3. Model Registry: Manage model lifecycle
4. Dagster: Orchestrate all steps
5. Deployment: REST API + batch
6. Monitoring: Metrics + alerts
7. CI/CD: Automated deployment
8. Documentation: Complete

**Deliverables:**
1. Code repository
2. README with setup instructions
3. Architecture diagram
4. Demo video (10-15 minutes)
5. Project report

### Evaluation Criteria

| Criteria | Weight | Description |
|----------|--------|-------------|
| Completeness | 25% | All requirements met |
| Code Quality | 20% | Clean, well-organized |
| Tool Integration | 20% | Proper tool usage |
| Documentation | 15% | Clear and complete |
| Presentation | 10% | Demo quality |
| Testing | 10% | Test coverage |

---

## 7.4 Grading Rubric

### Overall Grade Scale

| Percentage | Grade | Performance |
|------------|-------|-------------|
| 90-100% | A | Excellent |
| 80-89% | B | Good |
| 70-79% | C | Satisfactory |
| 60-69% | D | Needs Improvement |
| Below 60% | F | Unsatisfactory |

### Grade Calculation

```
Final Grade = (Quiz_Avg × 0.20) + 
             (Lab_Avg × 0.30) + 
             (Project × 0.30) + 
             (Participation × 0.10) + 
             (Final_Exam × 0.10)
```

---

# SECTION 8: ADDITIONAL RESOURCES

## 8.1 Trainer Resources

### Books for Trainers

| Title | Author | Description |
|-------|--------|-------------|
| Teach Like a Champion | Doug Lemov | Teaching techniques |
| The Art of Teaching | Gilbert Highet | Teaching philosophy |
| How Learning Works | Ambrose, et al. | Learning science |
| The First Days of School | Harry Wong | Classroom management |

### Teaching Tools

| Tool | Purpose | Link |
|------|---------|------|
| Menti | Interactive polls | https://menti.com |
| Kahoot | Quizzes | https://kahoot.com |
| Jamboard | Whiteboard | https://jamboard.google.com |
| GitHub Classroom | Assignment management | https://classroom.github.com |

---

## 8.2 Student Resources

### Quick Reference Cards

Create the following for students:
1. DVC Command Reference
2. MLflow API Reference
3. Dagster Decorator Reference
4. Python Type Hints Reference
5. Git Command Reference

### Study Materials

1. Practice exercises
2. Sample solutions
3. Troubleshooting guide
4. Architecture diagrams
5. Code snippets

---

## 8.3 Further Reading

### Recommended Books for Students

**MLOps:**
- "MLOps: An Introduction" by David S. Colling
- "Practical MLOps" by Noah Gift, et al.
- "Designing Machine Learning Systems" by Chip Huyen

**Data Engineering:**
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "Fundamentals of Data Engineering" by Reis & Housley

**DevOps:**
- "The DevOps Handbook" by Kim, et al.
- "Site Reliability Engineering" by Beyer, et al.

### Online Courses

| Course | Platform | Link |
|--------|----------|------|
| MLOps Specialization | Coursera | https://coursera.org |
| Machine Learning Engineering | Coursera | https://coursera.org |
| Data Engineering Zoomcamp | DataTalks | https://datatalks.club |

---

## 9. Conclusion

### Trainer Final Checklist

- [ ] All modules prepared
- [ ] Environment tested
- [ ] Materials ready
- [ ] Assessments created
- [ ] Backup plans in place
- [ ] Support channels ready
- [ ] Student resources available

### Course Success Tips

1. **Be Passionate:** Enthusiasm is contagious
2. **Be Prepared:** Know your material
3. **Be Patient:** Learning takes time
4. **Be Responsive:** Answer questions promptly
5. **Be Flexible:** Adapt to student needs
6. **Be Supportive:** Encourage participation
7. **Be Professional:** Set high standards
8. **Be Engaging:** Make it interesting
9. **Be Organized:** Keep things structured
10. **Be There:** Provide support throughout

---

*End of Trainer Guide*

---

## Quick Reference: Session Plan Template

### Module __: [Title]

**Date:** ____________
**Duration:** ____________
**Instructor:** ____________

**Learning Objectives:**
1. 
2. 
3. 

**Materials Needed:**
- [ ] Slides
- [ ] Code demos
- [ ] Lab instructions
- [ ] Assessment

**Timeline:**
| Time | Activity | Description |
|------|----------|-------------|
| | Welcome | |
| | Lecture | |
| | Demo | |
| | Lab | |
| | Review | |

**Notes:**

---

**Happy Teaching!**
