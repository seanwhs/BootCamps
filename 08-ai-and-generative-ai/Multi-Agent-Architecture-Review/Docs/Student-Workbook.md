# Multi-Agent AI Architecture Review System
# Student Workbook

---

## WELCOME & INTRODUCTION

### About This Workbook

This workbook is designed to accompany the "Multi-Agent AI Architecture Review System" tutorial series. It provides hands-on exercises, reflection questions, and practical activities to reinforce your learning.

**How to Use This Workbook:**
1. Read each section before starting the corresponding tutorial part
2. Complete the exercises as you go through the tutorials
3. Use the checkboxes to track your progress
4. Fill in the blanks and answer questions in the spaces provided
5. Save your work for future reference

**Student Information:**
- Name: _____________________________
- Date Started: _________________________
- Expected Completion: ___________________
- Learning Goals: ________________________________________________________________
_______________________________________________________________________________

---

## PART 0: INTRODUCTION
### Pre-Work Reflection

---

**Exercise 0.1: Self-Assessment**

Rate your current knowledge on a scale of 1-5 (1 = Beginner, 5 = Expert):

| Topic | Self-Rating (1-5) | Notes |
|-------|-------------------|-------|
| Python Programming | ___ | |
| System Design | ___ | |
| AI/LLM Concepts | ___ | |
| Git/Version Control | ___ | |
| API Integration | ___ | |
| Architecture Reviews | ___ | |

---

**Exercise 0.2: Expectations & Goals**

Answer the following questions before starting:

1. What is your primary reason for taking this course?
   _________________________________________________________________
   _________________________________________________________________

2. What specific problem are you trying to solve in your organization?
   _________________________________________________________________
   _________________________________________________________________

3. What do you hope to build or achieve by the end of this series?
   _________________________________________________________________
   _________________________________________________________________

4. What challenges do you anticipate?
   _________________________________________________________________
   _________________________________________________________________

---

## PART 1: FOUNDATIONS & TECHNICAL LANDSCAPE
### Student Activities

---

**Exercise 1.1: Architecture Review Challenges**

**Part A: List the challenges of single-architect reviews**

Fill in the table with the challenges discussed in the tutorial:

| Challenge | Description | Example |
|-----------|-------------|---------|
| 1. | | |
| 2. | | |
| 3. | | |
| 4. | | |
| 5. | | |

**Part B: Reflect on Your Experience**

Think about a recent architecture review you participated in:

- What went well? ___________________________________________________
- What challenges did you face? ____________________________________
- What issues were missed initially? _______________________________
- Would multiple reviewers have helped? Why or why not? ______________
_______________________________________________________________________

---

**Exercise 1.2: Technical Paradigms Comparison**

Complete the comparison table for the three technical paradigms:

| Criterion | Native Agent Teams | Persona Simulation | Orchestration Frameworks |
|-----------|-------------------|-------------------|------------------------|
| Repository Awareness | | | |
| Domain Specialization | | | |
| Governance | | | |
| Ease of Setup | | | |
| Customization | | | |
| Cost Control | | | |
| Collaboration | | | |
| Audit Trail | | | |

**Rank each criterion: ★ (Poor) to ★★★★★ (Excellent)**

**Reflection:** Which paradigm would you choose for your organization? Why?
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________

---

**Exercise 1.3: Setting Up the Environment**

**Hands-On Activity:**

Follow these steps to set up your development environment:

- [ ] Step 1: Create the project directory
  ```bash
  mkdir multi-agent-arch-review
  cd multi-agent-arch-review
  ```

- [ ] Step 2: Create the virtual environment
  ```bash
  python3.11 -m venv venv
  source venv/bin/activate  # macOS/Linux
  # OR
  venv\Scripts\activate     # Windows
  ```

- [ ] Step 3: Create the directory structure
  ```bash
  mkdir -p src/agents src/orchestration src/repository src/governance src/prompts src/utils
  mkdir -p tests docs/designs docs/adrs examples logs
  ```

- [ ] Step 4: Create the configuration files

  Create `.env` file:
  ```
  OPENAI_API_KEY=your-key-here
  DEFAULT_MODEL=gpt-4-turbo-preview
  REVIEW_BUDGET_USD=5.00
  LOG_LEVEL=INFO
  ```

- [ ] Step 5: Install dependencies
  ```bash
  pip install -r requirements.txt
  ```

- [ ] Step 6: Run the config verification
  ```bash
  python review.py config
  ```

**Troubleshooting Notes:**
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________

---

**Exercise 1.4: ADR Analysis**

**Part A: Review the Sample ADR**

Read ADR 0001: "Adopt Multi-Agent Orchestration Framework"

Complete the following analysis:

- **Context of the decision:**
  _________________________________________________________________

- **Decision made:**
  _________________________________________________________________

- **Three key rationales:**
  1. _______________________________________________________________
  2. _______________________________________________________________
  3. _______________________________________________________________

- **Positive consequences:**
  _________________________________________________________________

- **Negative consequences:**
  _________________________________________________________________

**Part B: Draft Your Own ADR**

Choose a recent architectural decision your team made. Draft an ADR following the MADR format:

```
# ADR 000X: [YOUR TITLE]

## Status
[PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED]

## Date
[YYYY-MM-DD]

## Context
[What is the situation? What forces are at play?]
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

## Decision
[What was decided?]
_________________________________________________________________
_________________________________________________________________

## Rationale
[Why was this decision made?]
_________________________________________________________________
_________________________________________________________________

## Consequences
[Positive and negative consequences]
_________________________________________________________________
_________________________________________________________________

## Alternatives Considered
[What other options were evaluated? Why rejected?]
_________________________________________________________________
_________________________________________________________________

## References
[Links to related documents]
_________________________________________________________________
```

---

**Exercise 1.5: Proof of Concept Run**

**Hands-On Activity:**

Run your first review and record the results:

1. Create a sample design document or use the provided one:

   [ ] Document created at: `docs/designs/my-first-design.md`

2. Run the review:
   ```bash
   python review.py review -d docs/designs/my-first-design.md -v
   ```

3. Record the results:

   - Review ID: ____________________________________________________
   - Model used: ___________________________________________________
   - Time taken: ___________________________________________________
   - Cost: ________________________________________________________

4. Review Output:

   - Summary of findings:
     _______________________________________________________________
     _______________________________________________________________
     _______________________________________________________________

   - Risk level: ___________________________________________________

   - Decision: _____________________________________________________

   - Key recommendations:
     1. ___________________________________________________________
     2. ___________________________________________________________
     3. ___________________________________________________________

5. Reflection:
   - What surprised you about the results?
     _______________________________________________________________
   - Were the findings actionable?
     _______________________________________________________________
   - How could the design be improved?
     _______________________________________________________________

---

## PART 2: DOMAIN SPECIALIZATION
### Student Activities

---

**Exercise 2.1: The Five Domains**

**Part A: Complete the Domain Descriptions**

Fill in the blanks:

| Domain | Focus | Key Checks |
|--------|-------|------------|
| Functional | Requirements & | • Complete requirements<br>• Domain boundaries<br>• User journeys |
| Security | & Compliance | • OWASP Top 10<br>• STRIDE modeling<br>• Authentication<br>• Encryption |
| Data | Schema & | • Normalization<br>• Data types<br>• Lifecycle<br>• Migration |
| DevOps | & Cloud | • CI/CD<br>• Containerization<br>• IaC<br>• Monitoring<br>• Cost |
| Reliability | Performance & | • Observability<br>• Caching<br>• Fault tolerance<br>• Performance |

**Part B: Domain Scenario Mapping**

For each of the following scenarios, indicate which domain(s) are affected and explain why:

| Scenario | Domain(s) | Why? |
|----------|-----------|------|
| Database credentials in config.yaml | | |
| No health check endpoint | | |
| Missing failed payment handling | | |
| No rate limiting on login | | |
| Schema without indexes | | |
| No load testing plan | | |

---

**Exercise 2.2: Creating a Validation Matrix**

**Hands-On Activity:**

Create a validation matrix for a new domain: **Accessibility (WCAG Compliance)**

Define at least 5 checks with appropriate priorities:

| Check ID | Description | Priority | Examples | Suggestions |
|----------|-------------|----------|----------|-------------|
| ACC-001 | | | | |
| ACC-002 | | | | |
| ACC-003 | | | | |
| ACC-004 | | | | |
| ACC-005 | | | | |

**Implementation:**

Write the Python code for this validation matrix:

```python
def get_accessibility_matrix() -> DomainMatrix:
    """Accessibility domain validation matrix."""
    checks = [
        # Your code here
        
    ]
    return DomainMatrix("Accessibility", checks)
```

---

**Exercise 2.3: Building a Domain Agent**

**Hands-On Activity:**

Complete the implementation of the Accessibility Agent:

```python
"""
Accessibility Agent - Reviews for WCAG compliance.
"""

from typing import Dict, Any, List
import json

from .base_agent import BaseAgent
from src.prompts.validation_matrix import get_accessibility_matrix

class AccessibilityAgent(BaseAgent):
    """
    Agent specialized in accessibility architecture review.
    
    Reviews:
    - WCAG 2.1 compliance
    - Screen reader compatibility
    - Keyboard navigation
    - Color contrast
    - Alternative text
    """
    
    def __init__(self, model: str = None):
        super().__init__("AccessibilityAgent", model)
        self.matrix = get_accessibility_matrix()
        self.logger.info("AccessibilityAgent initialized")
    
    def get_prompt(self, document: str) -> List[Dict[str, str]]:
        """Generate the accessibility review prompt."""
        # Fill in the system_prompt
        system_prompt = f"""
        You are the Accessibility Architecture Agent, a specialist in 
        reviewing software design documents for accessibility compliance.
        
        Your role is to ensure that:
        1. [Fill in requirement 1]
        2. [Fill in requirement 2]
        3. [Fill in requirement 3]
        
        Validation checklist:
        {self.matrix.to_prompt()}
        
        Return your analysis as JSON with:
        - summary: Overall accessibility assessment
        - findings: List of accessibility issues
        - overall_risk: LOW/MEDIUM/HIGH
        - score: 0-100
        - recommendation: Overall accessibility recommendation
        """
        
        # Fill in the user_prompt
        user_prompt = f"""
        Review this design document for accessibility concerns:
        
        {document}
        """
        
        return [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
    
    def review(self, document: str) -> Dict[str, Any]:
        """Review the document for accessibility issues."""
        # Fill in the implementation
        self.logger.info("Starting accessibility review")
        
        # Your code here
        
        # Return the result
        return {
            'domain': 'accessibility',
            'agent': self.name,
            'model': self.model,
            'summary': 'Review completed',
            'findings': [],
            'score': 100,
            'overall_risk': 'LOW'
        }
```

---

**Exercise 2.4: Agent Testing**

**Hands-On Activity:**

Test each agent and record the results:

**Functional Agent**
```bash
python -c "
from src.agents.functional_agent import FunctionalAgent
from pathlib import Path

agent = FunctionalAgent()
doc = Path('docs/designs/sample-payment-service.md').read_text()
result = agent.review(doc)
print(f'Score: {result.get(\"score\")}%')
print(f'Findings: {len(result.get(\"findings\", []))}')
"
```

**Results:**
- Score: ___________
- Findings: ___________
- Key Issues: _______________________________________________________
_______________________________________________________________________

**Security Agent**
- Score: ___________
- Findings: ___________
- Key Issues: _______________________________________________________
_______________________________________________________________________

**Data Agent**
- Score: ___________
- Findings: ___________
- Key Issues: _______________________________________________________
_______________________________________________________________________

**DevOps Agent**
- Score: ___________
- Findings: ___________
- Key Issues: _______________________________________________________
_______________________________________________________________________

**Reliability Agent**
- Score: ___________
- Findings: ___________
- Key Issues: _______________________________________________________
_______________________________________________________________________

**Reflection:** Which agent found the most critical issues?
_______________________________________________________________________
_______________________________________________________________________

---

**Exercise 2.5: Multi-Agent Review Run**

**Hands-On Activity:**

Run a full multi-agent review:

```bash
python review.py review -d docs/designs/sample-payment-service.md --mode multi -v
```

**Record the aggregated results:**

- Aggregate Score: __________%
- Overall Risk: ___________
- Total Findings: ___________
- Critical Findings: ___________
- High Findings: ___________

**Individual Agent Results:**

| Agent | Score | Risk | Findings |
|-------|-------|------|----------|
| Functional | | | |
| Security | | | |
| Data | | | |
| DevOps | | | |
| Reliability | | | |

**Reflection:**
- How do these results compare to the single-agent review?
  _________________________________________________________________
- What additional issues were found by the multi-agent review?
  _________________________________________________________________
- Which domain had the most issues? What does that tell you?
  _________________________________________________________________

---

## PART 3: FRAMEWORK SELECTION & ORCHESTRATION
### Student Activities

---

**Exercise 3.1: Framework Comparison**

**Part A: Research the Frameworks**

Complete this table based on the tutorial content and your own research:

| Framework | Strengths | Weaknesses | Best Use Case |
|-----------|-----------|------------|---------------|
| LangGraph | | | |
| CrewAI | | | |
| AutoGen | | | |
| OpenAI Swarm | | | |
| MetaGPT | | | |

**Part B: Framework Selection**

Which framework(s) would you choose for:
1. A simple, single-task agent system: _______________________________
2. A complex, stateful workflow with human approval: ___________________
3. A documentation generation team: ___________________________________
4. A multi-agent conversation with code execution: ____________________

Explain your choices:
_______________________________________________________________________
_______________________________________________________________________

---

**Exercise 3.2: LangGraph State Design**

**Hands-On Activity:**

Design a LangGraph state for a different workflow (e.g., a code review workflow with linters, tests, and human approval):

```python
class CodeReviewState(TypedDict):
    """State for the code review workflow."""
    
    # Define the state fields
    # Example: file_path, linter_results, test_results, human_approval
    
```

---

**Exercise 3.3: Building the LangGraph Workflow**

**Hands-On Activity:**

Complete the graph implementation:

```python
from langgraph.graph import StateGraph, END

# 1. Define the state (from Exercise 3.2)

# 2. Define the nodes
def run_linters(state: CodeReviewState) -> CodeReviewState:
    """Run linters on the code."""
    # Your code here
    return state

def run_tests(state: CodeReviewState) -> CodeReviewState:
    """Run tests on the code."""
    # Your code here
    return state

def human_review(state: CodeReviewState) -> CodeReviewState:
    """Human review gate."""
    # Your code here
    return state

# 3. Build the graph
workflow = StateGraph(CodeReviewState)
workflow.add_node("run_linters", run_linters)
workflow.add_node("run_tests", run_tests)
workflow.add_node("human_review", human_review)

# 4. Define the edges
# Add your edges here:

```

---

**Exercise 3.4: CrewAI Team Design**

**Hands-On Activity:**

Design a CrewAI team for a different use case: **Bug Report Triaging**

```python
from crewai import Agent, Task, Crew, Process

# 1. Define agents with roles, goals, and backstories

triage_agent = Agent(
    role="[Fill in role]",
    goal="[Fill in goal]",
    backstory="[Fill in backstory]",
    llm=your_llm,
    verbose=True
)

analysis_agent = Agent(
    role="[Fill in role]",
    goal="[Fill in goal]",
    backstory="[Fill in backstory]",
    llm=your_llm,
    verbose=True
)

# 2. Define tasks

triage_task = Task(
    description="""
    [Fill in task description]
    """,
    agent=triage_agent,
    expected_output="[Fill in expected output]"
)

analysis_task = Task(
    description="""
    [Fill in task description]
    """,
    agent=analysis_agent,
    expected_output="[Fill in expected output]"
)

# 3. Create the crew

bug_triage_crew = Crew(
    agents=[triage_agent, analysis_agent],
    tasks=[triage_task, analysis_task],
    process=Process.sequential,
    verbose=True
)

# 4. Kick off the crew
result = bug_triage_crew.kickoff()
```

---

**Exercise 3.5: Human-in-the-Loop Implementation**

**Hands-On Activity:**

Design a human-in-the-loop gate for the code review workflow:

**Gate Display Requirements:**
- Show linter results
- Show test results
- Show code coverage
- Provide approval/reject/retry options

**Implementation:**

```python
def human_review_gate(state: CodeReviewState) -> CodeReviewState:
    """Human review gate for code review."""
    
    # 1. Display information
    print("=" * 80)
    print("CODE REVIEW HUMAN GATE")
    print("=" * 80)
    print(f"\nFile: {state.get('file_path', 'Unknown')}")
    print(f"Linter Results: {state.get('linter_results', 'N/A')}")
    print(f"Test Results: {state.get('test_results', 'N/A')}")
    # Add more information
    
    # 2. Get human input
    # [Fill in the code]
    
    # 3. Update state
    # [Fill in the code]
    
    return state
```

---

## PART 4: PRODUCTION GOVERNANCE
### Student Activities

---

**Exercise 4.1: Repository Scanner Analysis**

**Hands-On Activity:**

Run the repository scanner on your project:

```bash
python review.py scan-repo --repo .
```

**Record the results:**

- Repository Path: __________________________________________________
- Branch: ___________________________________________________________
- Files Found: _______________________________________________________

**Files by Type:**

| Type | Count |
|------|-------|
| DESIGN_DOC | |
| ADR | |
| CONFIG | |
| SOURCE | |
| SCHEMA | |
| DOCKERFILE | |
| CI_CONFIG | |
| INFRA | |
| README | |
| UNKNOWN | |

**Reflection:**
- What types of files did you find? __________________________________
- Were there any files you expected to see but didn't? _________________
- What would you add to the file type patterns? _________________________
_______________________________________________________________________

---

**Exercise 4.2: RAG Search**

**Hands-On Activity:**

Run a RAG search on your repository:

```bash
python review.py search --query "Your search query here" --top 5
```

**Record the results:**

- Query: ____________________________________________________________

**Results:**

| Rank | File | Similarity | Content Preview |
|------|------|------------|-----------------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

**Reflection:**
- Did the search find what you expected? ______________________________
- What would make the search better? __________________________________
- How could RAG improve your architecture reviews? _____________________
_______________________________________________________________________

---

**Exercise 4.3: ADR Generation**

**Hands-On Activity:**

Generate an ADR from your review results:

```bash
python review.py generate-adr --review-file docs/outputs/your-review.json
```

**Record the ADR details:**

- ADR Number: ___________
- File Path: ________________________________________________________
- Status: ___________________________________________________________
- Summary: __________________________________________________________
_______________________________________________________________________

**Review the ADR:**

1. Is the status appropriate? ________________________________________
2. Are the critical issues correctly identified? _______________________
3. Are the consequences complete? ____________________________________
4. Would you approve this ADR? Why or why not? ________________________
_______________________________________________________________________

**Reflection:**
- How does the automated ADR compare to manually written ADRs?
  _________________________________________________________________
- What would you change about the ADR format?
  _________________________________________________________________

---

**Exercise 4.4: Permission Design**

**Hands-On Activity:**

Design a permission system for a new agent role:

**New Role Name:** ___________________________________________________

**Required Permissions:**

| Permission | Justification |
|------------|---------------|
| | |
| | |
| | |
| | |

**Implementation:**

```python
# Add the new role to ROLE_PERMISSIONS

ROLE_PERMISSIONS = {
    # ... existing roles ...
    'your_new_role': {
        # Your permissions
        Permission.YOUR_PERMISSION_1,
        Permission.YOUR_PERMISSION_2,
        # etc.
    }
}
```

---

**Exercise 4.5: Complete Production Run**

**Hands-On Activity:**

Run a complete production review with all features:

```bash
python review.py review -d docs/designs/your-design.md --repo . --use-rag --verbose
```

**Record the results:**

| Metric | Value |
|--------|-------|
| Review ID | |
| Document | |
| Model | |
| RAG Enabled | |
| Time to Complete | |
| Aggregate Score | |
| Overall Risk | |
| Total Findings | |
| Critical Findings | |
| High Findings | |
| Cost | |

**Outputs Generated:**

- [ ] Review Report: __________________________________________________
- [ ] ADR: __________________________________________________________
- [ ] Summary: ______________________________________________________
- [ ] JSON Results: _________________________________________________

**Reflection:**

1. How did the RAG context affect the review?
   _________________________________________________________________

2. What was the most valuable finding?
   _________________________________________________________________

3. What would you improve about the system?
   _________________________________________________________________

4. Would you use this system in production? Why or why not?
   _________________________________________________________________

---

## FINAL PROJECT

---

### Project: End-to-End System Implementation

**Objective:** Build a complete multi-agent architecture review system for your organization's specific needs.

**Requirements:**

1. **Custom Design Document**
   - Create a realistic design document for a system your organization might build
   - Include sections: Overview, Requirements, Architecture, Security, Data, DevOps, Reliability

2. **New Domain Agent (Optional)**
   - Add a new domain agent for a domain not covered by the default five
   - Examples: Compliance (GDPR/HIPAA), Accessibility, Internationalization

3. **Custom Orchestration**
   - Modify the orchestrator to include your new agent
   - Add custom human gate logic if needed

4. **Production Run**
   - Run the complete review on your design document
   - Generate the review report, ADR, and summary

5. **Documentation**
   - Document your changes
   - Write a summary of findings
   - Propose next steps for the design

**Deliverables:**

| Deliverable | Status (☐/☑) |
|-------------|--------------|
| Design Document | |
| New Agent Code (if applicable) | |
| Orchestrator Modifications | |
| Review Report | |
| Generated ADR | |
| Summary of Findings | |
| Next Steps Document | |

---

### Project Reflection

**Part A: Technical Reflection**

1. What was the most challenging part of the project?
   _________________________________________________________________
   _________________________________________________________________

2. What was the most rewarding part?
   _________________________________________________________________
   _________________________________________________________________

3. What did you learn that you didn't know before?
   _________________________________________________________________
   _________________________________________________________________

**Part B: Organizational Impact**

4. How could this system benefit your organization?
   _________________________________________________________________
   _________________________________________________________________

5. What obstacles might you face in adopting this system?
   _________________________________________________________________
   _________________________________________________________________

6. How would you overcome those obstacles?
   _________________________________________________________________
   _________________________________________________________________

**Part C: Future Development**

7. What would you add to the system next?
   _________________________________________________________________
   _________________________________________________________________

8. How could the system be improved?
   _________________________________________________________________
   _________________________________________________________________

---

## SELF-ASSESSMENT CHECKLIST

---

### Knowledge Check

| Topic | I understand this | I need more practice |
|-------|-------------------|---------------------|
| Why single-architect reviews fail | ☐ | ☐ |
| Three technical paradigms | ☐ | ☐ |
| Setting up the environment | ☐ | ☐ |
| ADR structure and purpose | ☐ | ☐ |
| The five quality domains | ☐ | ☐ |
| Validation matrices | ☐ | ☐ |
| Building specialized agents | ☐ | ☐ |
| LangGraph orchestration | ☐ | ☐ |
| CrewAI documentation | ☐ | ☐ |
| Human-in-the-loop gates | ☐ | ☐ |
| Repository scanning | ☐ | ☐ |
| RAG implementation | ☐ | ☐ |
| ADR generation | ☐ | ☐ |
| Permissions and sandboxing | ☐ | ☐ |
| Audit logging | ☐ | ☐ |
| Cost tracking | ☐ | ☐ |

---

### Skill Check

| Skill | I can do this independently | I need support |
|-------|----------------------------|----------------|
| Set up the development environment | ☐ | ☐ |
| Create a validation matrix | ☐ | ☐ |
| Build a domain agent | ☐ | ☐ |
| Run a multi-agent review | ☐ | ☐ |
| Interpret review results | ☐ | ☐ |
| Generate an ADR | ☐ | ☐ |
| Scan a repository | ☐ | ☐ |
| Use RAG for context | ☐ | ☐ |
| Configure permissions | ☐ | ☐ |
| View audit logs | ☐ | ☐ |
| Monitor costs | ☐ | ☐ |
| Customize the system | ☐ | ☐ |

---

## NOTES & RESOURCES

---

### Key Terms & Definitions

| Term | Definition |
|------|------------|
| ADR | Architectural Decision Record - Documents an important architectural decision |
| Agent | AI program that perceives, reasons, acts, and learns |
| CrewAI | Role-based multi-agent framework for collaboration |
| Embedding | Vector representation of text for semantic search |
| Human-in-the-Loop | Workflow that pauses for human approval |
| IaC | Infrastructure as Code |
| LangGraph | State graph orchestration framework |
| LLM | Large Language Model |
| MADR | Markdown Architectural Decision Records |
| OWASP | Open Web Application Security Project |
| Orchestration | Coordinating multiple agents in a workflow |
| RAG | Retrieval-Augmented Generation |
| Sandboxing | Restricting operations for security |
| STRIDE | Threat modeling methodology |
| Validation Matrix | Structured checklist for domain agents |

---

### Commands Quick Reference

| Command | Purpose |
|---------|---------|
| `python review.py config` | Display configuration |
| `python review.py review -d design.md` | Run a review |
| `python review.py review -d design.md --mode unified` | Run unified review |
| `python review.py generate-adr -r review.json` | Generate ADR |
| `python review.py scan-repo --repo .` | Scan repository |
| `python review.py search -q "query"` | RAG search |
| `python review.py audit` | View audit log |
| `python review.py cost` | View cost report |
| `python review.py status` | System status |
| `python review.py list` | List checkpoints |
| `python review.py resume --thread-id ID` | Resume review |
| `python review.py version` | Version info |

---

### Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| ModuleNotFoundError | `pip install -r requirements.txt` |
| API key not configured | Add to .env file |
| Rate limit exceeded | Retry with exponential backoff |
| JSON parse error | Use safe_json_parse with fallbacks |
| Memory error | Use batch processing, limit file sizes |
| Git error | Verify repository path, init if needed |
| Permission denied | Run as appropriate user, check permissions |

---

### Resources for Further Learning

**Documentation:**
- LangGraph: https://langchain-ai.github.io/langgraph/
- CrewAI: https://docs.crewai.com/
- OpenAI API: https://platform.openai.com/docs
- Sentence Transformers: https://www.sbert.net/

**Standards:**
- OWASP Top 10: https://owasp.org/Top10/
- STRIDE: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- MADR: https://adr.github.io/madr/
- WCAG: https://www.w3.org/WAI/standards-guidelines/wcag/

**Books:**
- "Building Microservices" - Sam Newman
- "Domain-Driven Design" - Eric Evans
- "The Phoenix Project" - Gene Kim

---

## COMPLETION CERTIFICATE

---

### Student Completion Record

**Student Name:** ___________________________________________________

**Course:** Multi-Agent AI Architecture Review System

**Date Started:** ___________________________________________________

**Date Completed:** ___________________________________________________

**Completed Sections:**

| Section | Status | Date Completed |
|---------|--------|----------------|
| Part 0: Introduction | ☐ | |
| Part 1: Foundations | ☐ | |
| Part 2: Domain Specialization | ☐ | |
| Part 3: Orchestration | ☐ | |
| Part 4: Production Governance | ☐ | |
| Final Project | ☐ | |

**Self-Assessment:** I understand the concepts and can apply them.

☐ Yes ☐ No ☐ Need more practice

**Instructor/Reviewer Comments:**

_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________

---

*This workbook is part of the Multi-Agent AI Architecture Review System tutorial series. For more information, visit [your-repository-url].*

---

**END OF STUDENT WORKBOOK**
