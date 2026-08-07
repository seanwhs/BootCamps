# Trainer Guide: Beyond CVEs - The Evolution of Software Composition Analysis

## Complete Instructor's Guide for Teaching This Course

---

## TABLE OF CONTENTS

1. **Course Overview** - What you'll be teaching
2. **Lesson Plans** - Detailed session plans for each phase
3. **Teaching Tips** - Best practices for delivery
4. **Activities** - Interactive exercises
5. **Discussion Questions** - For group engagement
6. **Assessment Guide** - Grading and evaluation
7. **Classroom Setup** - Technical requirements
8. **Troubleshooting** - Common issues and solutions
9. **Additional Resources** - For further learning

---

## 1. COURSE OVERVIEW

### Course Description

This course teaches students how to build a complete, production-ready, AI-augmented software supply chain security system. Students will learn:

- How JavaScript packages execute during installation
- How to detect malicious package behavior
- How to build scalable security scanners
- How to integrate AI into security workflows
- How to deploy security tools in CI/CD pipelines

### Target Audience

- **Prerequisites:** Basic JavaScript/Node.js, npm, command-line comfort
- **No prior security experience required**
- **No AI/ML expertise required**
- **No DevOps experience required**

### Learning Outcomes

By the end of this course, students will be able to:

1. Explain the evolution of SCA from CVE matching to behavioral analysis
2. Detect sophisticated supply chain attacks
3. Build production-ready security scanning tools
4. Integrate LLMs responsibly into security workflows
5. Deploy security systems in CI/CD pipelines

### Course Structure

| Module | Phase | Duration | Focus |
|--------|-------|----------|-------|
| 1 | Introduction | 0.5 hours | Course overview, setup |
| 2 | Phase 1 | 4 hours | Foundations: Understanding the Threat |
| 3 | Phase 2 | 4 hours | Modern Dependency Risk Analysis |
| 4 | Phase 3 | 3 hours | Async Execution & Orchestration |
| 5 | Phase 4 | 3 hours | AI-Augmented Security |
| 6 | Labs | 2 hours | Hands-on exercises |
| 7 | Final Project | 2 hours | Complete system build |

---

## 2. LESSON PLANS

### Lesson 1: Introduction (0.5 hours)

#### Objectives
- Understand course scope and expectations
- Set up development environment
- Complete pre-course self-assessment

#### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:05 | Welcome and course overview |
| 0:05 - 0:10 | Review learning objectives and outcomes |
| 0:10 - 0:15 | Environment setup walkthrough |
| 0:15 - 0:20 | Demonstrate what students will build |
| 0:20 - 0:25 | Pre-course self-assessment |
| 0:25 - 0:30 | Q&A |

#### Teaching Materials
- [ ] Slide deck: Part 0 - Introduction
- [ ] Student workbook: Part 0
- [ ] Environment setup checklist
- [ ] Pre-course self-assessment form

#### Key Messages
1. Modern SCA goes beyond CVE matching
2. Behavioral analysis detects unknown threats
3. AI augments, doesn't replace, human judgment
4. Students will build a production-ready system

---

### Lesson 2: Phase 1 - Foundations (4 hours)

#### Part 1: JavaScript Execution Model (1 hour)

##### Objectives
- Understand call stack, heap, and event loop
- Explain microtask vs macrotask priority
- Identify how malicious packages exploit the event loop

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:15 | Lecture: JavaScript execution model |
| 0:15 - 0:25 | Demo: Call stack visualizer |
| 0:25 - 0:35 | Demo: Event loop priority |
| 0:35 - 0:45 | Hands-on: Run the visualizers |
| 0:45 - 0:55 | Discussion: Security implications |
| 0:55 - 1:00 | Q&A |

##### Key Concepts
- The call stack is LIFO (Last In, First Out)
- The heap stores objects and functions
- The event loop manages asynchronous operations
- Microtasks have higher priority than macrotasks
- Malicious packages exploit execution order

##### Teaching Tips
- Use the restaurant analogy (waiter/chef)
- Emphasize that setTimeout(0) is NOT immediate
- Show `process.nextTick` as the most dangerous
- Explain event loop starvation with visual examples

##### Demonstration Script
```bash
# Run the call stack visualizer
node phase-1/01-call-stack-visualizer.js

# Run the event loop priority demo
node phase-1/02-event-loop-priority.js

# Run the malicious simulation
node phase-1/03-malicious-simulation.js
```

---

#### Part 2: npm Install Lifecycle (1 hour)

##### Objectives
- Identify all npm lifecycle phases
- Understand security implications of each phase
- Detect suspicious install scripts

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:15 | Lecture: npm install lifecycle |
| 0:15 - 0:25 | Demo: Package analyzer |
| 0:25 - 0:35 | Hands-on: Create test packages |
| 0:35 - 0:45 | Hands-on: Run package analyzer |
| 0:45 - 0:55 | Discussion: Risk assessment |
| 0:55 - 1:00 | Q&A |

##### Key Concepts
- Lifecycle scripts: preinstall, install, postinstall
- `postinstall` is the most common attack vector
- Scripts run with user permissions
- `postinstall` scripts execute after installation, when developers are less likely to monitor
- Always review scripts before installing

##### Security Implication Matrix

| Phase | Description | Risk Level | Attack Vector |
|-------|-------------|------------|---------------|
| preinstall | Runs BEFORE installation | HIGH | Reconnaissance |
| install | Runs DURING installation | CRITICAL | Shell commands |
| postinstall | Runs AFTER installation | CRITICAL | Data exfiltration |
| prepare | Runs on install and publish | HIGH | Build-time attacks |
| preuninstall | Runs before removal | MEDIUM | Persistence |

##### Teaching Tips
- Emphasize that `postinstall` is most dangerous because:
  - It runs after the developer has moved on
  - It has full permissions
  - It's often overlooked in security reviews
- Show real examples of malicious scripts
- Demonstrate `--ignore-scripts` as a safeguard

---

#### Part 3: Building the Scanner (1.5 hours)

##### Objectives
- Build a complete security scanner
- Implement risk scoring
- Generate security reports
- Integrate with CI/CD

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:15 | Lecture: Scanner architecture |
| 0:15 - 0:25 | Walkthrough: Scanner code |
| 0:25 - 0:45 | Hands-on: Run the scanner |
| 0:45 - 0:55 | Walkthrough: CI/CD integration |
| 0:55 - 1:15 | Hands-on: Test different packages |
| 1:15 - 1:25 | Discussion: Risk scoring |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- Scanner architecture: parse → scan → analyze → report
- Detection patterns: shell, network, filesystem, environment
- Risk scoring: severity + frequency
- CI/CD integration: fail builds on critical issues

##### Risk Scoring System

| Severity | Points | Action |
|----------|--------|--------|
| CRITICAL | 25 | Immediate block |
| HIGH | 15 | Urgent review |
| MEDIUM | 8 | Scheduled review |
| LOW | 3 | Monitor |
| INFO | 0 | No action |

##### Teaching Tips
- Walk through the scanner code line by line
- Show how detection patterns work
- Demonstrate risk scoring with examples
- Show CI/CD integration in GitHub Actions

---

#### Part 4: Phase 1 Wrap-up (30 minutes)

##### Objectives
- Review key concepts
- Answer questions
- Complete assessment

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:10 | Summary of key takeaways |
| 0:10 - 0:15 | Module 1 review questions |
| 0:15 - 0:25 | Group discussion |
| 0:25 - 0:30 | Next steps and preview of Phase 2 |

##### Key Takeaways
1. JavaScript execution model is crucial for security
2. npm lifecycle scripts are a major attack vector
3. Behavioral detection catches threats before CVEs
4. Risk scoring helps prioritize remediation
5. CI/CD integration automates security enforcement

---

### Lesson 3: Phase 2 - Modern Dependency Risk Analysis (4 hours)

#### Part 1: Package Manifest Analysis (1.5 hours)

##### Objectives
- Parse and analyze package.json and lock files
- Detect dependency confusion attacks
- Identify typosquatting attempts
- Assess package health and trust

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:20 | Lecture: Package analysis |
| 0:20 - 0:30 | Demo: Package analyzer |
| 0:30 - 0:50 | Hands-on: Run the analyzer |
| 0:50 - 1:10 | Lecture: Dependency confusion |
| 1:10 - 1:25 | Hands-on: Detect dependency confusion |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- package.json: metadata, scripts, dependencies
- Lock files: exact versions, integrity hashes
- Dependency confusion: public versions of private packages
- Typosquatting: similar names to popular packages
- Health and trust scores: maintainer reputation

##### Teaching Tips
- Show real examples of dependency confusion
- Demonstrate typosquatting with examples
- Explain how to calculate trust scores
- Discuss the importance of lock files

---

#### Part 2: Capability Scanning (1.5 hours)

##### Objectives
- Analyze package source code for capabilities
- Detect dangerous capabilities
- Score capabilities by risk level

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:15 | Lecture: Capability scanning |
| 0:15 - 0:30 | Demo: Capability scanner |
| 0:30 - 0:50 | Hands-on: Run capability scanner |
| 0:50 - 1:10 | Lecture: AST analysis |
| 1:10 - 1:25 | Hands-on: Test with different packages |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- Capabilities: what packages CAN do
- AST analysis: safe code analysis
- Capability types: shell, network, filesystem
- Risk levels: CRITICAL, HIGH, MEDIUM, LOW

##### Teaching Tips
- Explain AST analysis with visual diagrams
- Show how different capabilities are detected
- Demonstrate risk scoring with examples

---

#### Part 3: Socket vs. Snyk Comparison (1 hour)

##### Objectives
- Understand the different approaches of Socket and Snyk
- Integrate both tools into a unified system
- Compare and contrast their findings
- Generate comprehensive security reports

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:20 | Lecture: Socket vs Snyk |
| 0:20 - 0:30 | Demo: Socket integration |
| 0:30 - 0:40 | Demo: Snyk integration |
| 0:40 - 0:50 | Hands-on: Comparative analysis |
| 0:50 - 0:55 | Discussion: When to use each tool |
| 0:55 - 1:00 | Q&A |

##### Key Concepts
- Socket: behavioral analysis, supply chain security
- Snyk: vulnerability detection, remediation
- Comparative analysis: best of both worlds
- Unified reporting: actionable insights

##### Teaching Tips
- Explain when to use each tool
- Show how they complement each other
- Demonstrate unified reporting
- Discuss integration strategies

---

### Lesson 4: Phase 3 - Async Execution & Orchestration (3 hours)

#### Part 1: Concurrency Patterns (1.5 hours)

##### Objectives
- Understand JavaScript concurrency models
- Implement worker pools
- Manage concurrent operations
- Handle timeouts and cancellations

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:20 | Lecture: Concurrency models |
| 0:20 - 0:30 | Demo: Concurrency controller |
| 0:30 - 0:50 | Hands-on: Run concurrency tests |
| 0:50 - 1:10 | Lecture: Resource management |
| 1:10 - 1:25 | Hands-on: Resource monitoring |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- Concurrency models: sequential, parallel, pipeline
- Worker pool pattern
- Resource management: memory, CPU, file handles
- Timeout and cancellation: AbortController

##### Teaching Tips
- Use the restaurant analogy
- Show performance differences
- Demonstrate resource monitoring
- Explain graceful degradation

---

#### Part 2: Priority Queuing and Orchestration (1.5 hours)

##### Objectives
- Implement priority-based queuing
- Manage multiple queue levels
- Handle priority inversions
- Build the complete orchestrator

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:20 | Lecture: Priority queuing |
| 0:20 - 0:30 | Demo: Priority queue |
| 0:30 - 0:50 | Hands-on: Test priority queuing |
| 0:50 - 1:10 | Lecture: Orchestrator |
| 1:10 - 1:25 | Hands-on: Run the orchestrator |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- Priority levels: critical, high, medium, low, background
- Priority aging: prevent starvation
- Orchestrator: coordinates all components
- Streaming results: real-time processing

##### Teaching Tips
- Explain priority with examples
- Show priority aging in action
- Demonstrate the complete orchestrator
- Discuss production considerations

---

### Lesson 5: Phase 4 - AI-Augmented Security (3 hours)

#### Part 1: LLM Integration (1.5 hours)

##### Objectives
- Integrate LLM APIs (OpenAI, Anthropic)
- Generate structured security analysis
- Validate AI outputs
- Handle API failures gracefully

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:20 | Lecture: LLM integration |
| 0:20 - 0:30 | Demo: LLM service |
| 0:30 - 0:50 | Hands-on: Run AI analysis |
| 0:50 - 1:10 | Lecture: Schema validation |
| 1:10 - 1:25 | Hands-on: Validate outputs |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- LLM integration: OpenAI, Anthropic
- Structured outputs: JSON schema
- Validation: reject malformed responses
- Fallback: handle API failures

##### Teaching Tips
- Emphasize "AI recommends, policies decide"
- Show validation in action
- Demonstrate fallback strategies
- Discuss cost considerations

---

#### Part 2: CI/CD Integration (1.5 hours)

##### Objectives
- Integrate with GitHub Actions
- Implement webhook endpoints
- Send notifications (Slack, Email, Teams)
- Generate CI/CD-ready reports

##### Agenda

| Time | Activity |
|------|----------|
| 0:00 - 0:20 | Lecture: CI/CD integration |
| 0:20 - 0:30 | Demo: GitHub Actions |
| 0:30 - 0:40 | Demo: Webhook server |
| 0:40 - 1:00 | Hands-on: Run CI/CD integration |
| 1:00 - 1:10 | Demo: Notifications |
| 1:10 - 1:25 | Discussion: Production deployment |
| 1:25 - 1:30 | Q&A |

##### Key Concepts
- GitHub Actions: workflow configuration
- Webhooks: event-driven integration
- Notifications: Slack, Email, Teams
- Production deployment: Docker, Kubernetes

##### Teaching Tips
- Show complete workflow
- Demonstrate webhook endpoints
- Explain notification channels
- Discuss production considerations

---

## 3. TEACHING TIPS

### General Tips

1. **Start with the "why"** - Explain the importance of supply chain security before diving into code.
2. **Use analogies** - The restaurant analogy helps explain the event loop. The airport security analogy explains Socket vs Snyk.
3. **Live demos** - Always show the code working before students try it themselves.
4. **Encourage questions** - Create a safe space for students to ask questions.
5. **Pace yourself** - Don't rush through complex topics.

### Code Teaching Tips

1. **Read code aloud** - Explain what each line does as you read it.
2. **Use visual aids** - Draw diagrams for complex concepts.
3. **Point to the screen** - Use a laser pointer to highlight specific code.
4. **Show errors** - Demonstrate common errors and how to fix them.
5. **Encourage experimentation** - Let students modify the code.

### Discussion Facilitation

1. **Ask open-ended questions** - "Why do you think this is dangerous?"
2. **Encourage debate** - "When would you use Socket vs Snyk?"
3. **Share experiences** - Ask students about their security experiences.
4. **Use real examples** - Reference real supply chain attacks.
5. **Summarize frequently** - Review key points throughout.

---

## 4. ACTIVITIES

### Icebreaker Activity: Security Stories

**Duration:** 10 minutes

**Instructions:**
1. Ask students to share an experience with a security issue (any context)
2. Discuss what could have been done differently
3. Connect to supply chain security concepts

### Group Activity: Risk Assessment

**Duration:** 20 minutes

**Instructions:**
1. Provide a package.json file with suspicious content
2. Ask groups to identify all risks
3. Have groups present their findings
4. Compare risk assessments

### Pair Programming: Scanner Extension

**Duration:** 30 minutes

**Instructions:**
1. Pair students together
2. Ask them to add a new detection rule
3. Test the rule on sample packages
4. Share results with the class

---

## 5. DISCUSSION QUESTIONS

### Phase 1 Discussion Questions

1. Why is `process.nextTick` more dangerous than `setTimeout`?
2. How can the event loop be used for data exfiltration?
3. What makes `postinstall` scripts the most common attack vector?
4. Should you trust a package with no CVEs?
5. How would you detect event loop starvation?

### Phase 2 Discussion Questions

1. How does dependency confusion differ from typosquatting?
2. What information does a lock file provide that package.json doesn't?
3. Why is AST analysis safer than executing code?
4. When would you choose Socket over Snyk?
5. How can you measure package trustworthiness?

### Phase 3 Discussion Questions

1. What is the optimal concurrency level for scanning?
2. How would you handle memory pressure in the scanner?
3. Why is priority aging important?
4. What are the trade-offs in resource management?
5. How would you scale the scanner to 10,000 packages?

### Phase 4 Discussion Questions

1. Why should AI never be the authoritative decision-maker?
2. How would you handle malformed AI responses?
3. What are the security implications of using AI in CI/CD?
4. How do you balance AI assistance with deterministic policies?
5. What is the role of human oversight in AI-augmented security?

---

## 6. ASSESSMENT GUIDE

### Formative Assessment

| Method | When | Purpose |
|--------|------|---------|
| **Exit tickets** | End of each session | Check understanding |
| **Code reviews** | During labs | Assess code quality |
| **Peer feedback** | During pair programming | Collaborative learning |
| **Quick quizzes** | Start of sessions | Review previous content |

### Summative Assessment

| Assessment | Weight | Format |
|------------|--------|--------|
| **Module quizzes** | 30% | Multiple choice, short answer |
| **Lab assignments** | 30% | Code submission, report |
| **Final project** | 40% | Complete system, presentation |

### Grading Rubric: Final Project

| Criteria | Excellent (90-100%) | Good (70-89%) | Satisfactory (50-69%) | Needs Improvement (<50%) |
|----------|---------------------|---------------|-----------------------|--------------------------|
| **Functionality** | All features work perfectly | Most features work | Some features work | Few features work |
| **Code Quality** | Clean, well-documented | Mostly clean | Some issues | Poor quality |
| **Security** | Comprehensive coverage | Good coverage | Basic coverage | Limited coverage |
| **Documentation** | Excellent | Good | Some | Little or none |
| **Presentation** | Clear, professional | Clear | Somewhat clear | Unclear |

---

## 7. CLASSROOM SETUP

### Technical Requirements

#### Hardware
- Instructor computer with projector/LED screen
- Each student needs a computer (laptop recommended)
- Stable internet connection

#### Software
- Node.js 18.x or higher
- npm 9.x or higher
- Code editor (VS Code recommended with ESLint extension)
- Git
- Command-line terminal

#### VS Code Extensions (Recommended)
1. **ESLint** - Code quality
2. **Prettier** - Code formatting
3. **npm Intellisense** - Autocomplete for npm modules
4. **GitLens** - Git integration

#### Classroom Environment Setup

```bash
# Pre-class setup script
#!/bin/bash

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install npm
sudo npm install -g npm@latest

# Install VS Code extensions
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension christian-kohler.npm-intellisense

# Clone tutorial repository
git clone https://github.com/your-org/beyond-cves-tutorial.git
cd beyond-cves-tutorial
npm install
```

### Classroom Setup Checklist

- [ ] Projector/LED screen working
- [ ] Audio system working
- [ ] All student computers connected
- [ ] Repository cloned on instructor machine
- [ ] Repository cloned on student machines
- [ ] Dependencies installed
- [ ] API keys distributed (if needed)
- [ ] Internet connection stable

### Time Management Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TIME MANAGEMENT                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Set the Ground Rules:                                                      │
│  • Parking lot for off-topic questions                                     │
│  • "Three before me" - ask 3 peers before asking instructor               │
│  • "10-minute rule" - if stuck for 10 min, ask for help                  │
│                                                                              │
│  Pacing Indicators:                                                        │
│  • 5 min: Students should be typing the code                              │
│  • 10 min: Students should have code running                              │
│  • 20 min: Students should be discussing results                         │
│  • 30 min: Students should be ready for next topic                       │
│                                                                              │
│  Warning Signs:                                                            │
│  • >50% of class not following → slow down, re-explain                   │
│  • >50% of class finished → provide extension exercises                  │
│  • >3 people stuck on same issue → stop class and address               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. TROUBLESHOOTING

### Common Classroom Issues

| Issue | Solution |
|-------|----------|
| **API rate limiting** | Use cached responses, stagger requests |
| **Environment variable issues** | Create .env file, check permissions |
| **Node version compatibility** | Use nvm to switch versions |
| **Memory exhaustion** | Reduce concurrency, increase heap size |
| **Module not found** | Run `npm install`, check path |
| **Permission errors** | Check file permissions, use `sudo` if needed |

### Quick Fixes

```bash
# Node version issues
nvm install 18
nvm use 18

# Dependency issues
rm -rf node_modules package-lock.json
npm install

# Permission issues
chmod +x *.js

# Memory issues
node --max-old-space-size=4096 script.js

# Environment issues
source .env
export $(cat .env | xargs)
```

### Student Support

```markdown
Common Error: "Cannot find module 'chalk'"
Solution: npm install --save-dev chalk

Common Error: "SyntaxError: Cannot use import statement outside a module"
Solution: Add "type": "module" to package.json or use .mjs extension

Common Error: "Error: ENOSPC: no space left on device"
Solution: Clear node_modules: rm -rf node_modules/*

Common Error: "Error: EACCES: permission denied"
Solution: Check file permissions: chmod +x script.js

Common Error: "Error: connect ECONNREFUSED"
Solution: Check internet connection, proxy settings
```

---

## 9. ADDITIONAL RESOURCES

### For Further Learning

#### Books
1. **"The Tangled Web"** - Michal Zalewski
2. **"Web Application Security"** - Andrew Hoffman
3. **"Node.js Security"** - Liran Tal

#### Online Courses
1. **"OWASP Top 10"** - OWASP Foundation
2. **"Supply Chain Security"** - SANS Institute
3. **"Secure Coding"** - Coursera

#### Videos
1. **"The Event Loop"** - Philip Roberts (YouTube)
2. **"npm Security"** - GitHub Universe talks
3. **"Socket vs Snyk"** - Security conferences

### Teaching Community

- **OWASP Slack** - security professionals
- **npm Security WG** - npm security discussions
- **GitHub Security Lab** - vulnerability research

### Continuous Improvement

```markdown
## Post-Class Survey Questions

1. What was the most valuable part of this course?
2. What would you add to this course?
3. What would you remove from this course?
4. How would you rate the pace of the course?
5. How confident are you in building security scanners now?
6. What topics need more time?
7. What topics could be compressed?

## Teaching Journal Prompts

1. What went well today?
2. What could have been better?
3. Were all students engaged?
4. Did students meet the learning objectives?
5. What adjustments should I make for next time?
```

---

## CONCLUSION

### Final Tips for Trainers

1. **Stay current** - Security threats evolve rapidly. Stay up to date with the latest attacks.
2. **Be patient** - Some students may struggle with complex concepts.
3. **Celebrate success** - Recognize when students complete tasks.
4. **Continuous improvement** - Iterate on course content based on feedback.
5. **Build community** - Encourage students to help each other.

### What Makes This Course Unique

1. **Hands-on**: Students build a complete system, not just watch demos.
2. **Real-world**: Uses real attacks and real tools.
3. **Production-ready**: Code is production quality, not just demos.
4. **AI-augmented**: Shows how to use AI responsibly in security.
5. **Comprehensive**: Covers the entire supply chain security landscape.

---

**[END OF TRAINER GUIDE]**
