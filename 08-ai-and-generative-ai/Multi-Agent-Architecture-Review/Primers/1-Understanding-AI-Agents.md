# Primer 1: Understanding AI Agents - A Beginner's Guide

## P1.1 What is an AI Agent?

### The Concept

Imagine you have a personal assistant. You give them a task, and they figure out how to complete it. They might need to research, make decisions, use tools, and sometimes ask you for clarification. They work autonomously but within the boundaries you've set.

An **AI Agent** is exactly that, but digital. It's a software program that:

1. **Perceives** its environment (reads documents, accesses APIs)
2. **Reasons** about what it perceives (analyzes, makes decisions)
3. **Acts** to achieve a goal (generates responses, takes actions)
4. **Learns** from feedback (improves over time)

### A Real-World Analogy

Think of a travel agent booking a complex trip for you:

```
You: "I want to go to Paris for 2 weeks in July"

Travel Agent:
1. Perceives: Reads your request, checks dates
2. Reasons: Considers budget, weather, availability
3. Acts: Books flights, hotels, activities
4. Learns: Remembers your preferences for next time
```

An AI Agent works similarly, but for digital tasks like reviewing architecture documents.

### Why "Agent" and Not Just "AI"?

There's a key difference:

| Simple AI | AI Agent |
|-----------|----------|
| Responds to prompts | Takes initiative |
| No memory | Remembers context |
| One-shot responses | Multi-step workflows |
| Passive | Active |
| No tools | Uses tools |

An AI agent can:
- Plan a multi-step approach
- Remember what it has done
- Decide when to use tools
- Ask for help when stuck

---

## P1.2 The Components of an AI Agent

### The Architecture

Think of an AI agent as a small team, each part playing a specific role:

```
┌─────────────────────────────────────────────────────────┐
│                    AI AGENT                             │
│  ┌───────────────────────────────────────────────────┐ │
│  │             1. Brain (LLM)                        │ │
│  │   • Understands language                         │ │
│  │   • Reasons about problems                      │ │
│  │   • Makes decisions                             │ │
│  └───────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────┐ │
│  │             2. Memory                            │ │
│  │   • Short-term: Current conversation            │ │
│  │   • Long-term: Past interactions                │ │
│  │   • External: Documents, databases              │ │
│  └───────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────┐ │
│  │             3. Tools                             │ │
│  │   • APIs: Talk to other services                │ │
│  │   • Files: Read and write documents             │ │
│  │   • Code: Execute scripts                       │ │
│  └───────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────┐ │
│  │             4. Goal                              │ │
│  │   • What we're trying to achieve                │ │
│  │   • Success criteria                            │ │
│  │   • Constraints (budget, time)                  │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Breaking It Down

**1. The Brain (LLM - Large Language Model)**

This is the intelligence of the agent. It's a massive neural network trained on vast amounts of text. When you give it a prompt, it predicts the most likely response based on patterns it has learned.

```
Simple explanation: It's like a very well-read friend who
has memorized millions of books and can draw on that
knowledge to help you with any question.
```

**2. Memory**

Agents need to remember things to be useful:

```
Short-term memory:
  "The user just asked about authentication"

Long-term memory:
  "Last week, the user preferred JWT tokens over sessions"

External memory:
  "Let me check the documentation for this API"
```

**3. Tools**

Agents can use tools to extend their capabilities:

```
Agent: "I need to check if this code has security issues"
Tool: "Let me scan the code for common vulnerabilities"
Result: "Found 3 hardcoded secrets"

Agent: "I need to read a file"
Tool: "FileReader.read('/path/to/file')"
Result: "Here's the content..."
```

**4. Goal**

Every agent needs a clear purpose:

```
Security Agent Goal:
  "Find all security vulnerabilities in this design"
  
Data Agent Goal:
  "Ensure the data model follows best practices"
  
Documentation Agent Goal:
  "Create a clear ADR from review results"
```

---

## P1.3 How Agents Think: The Decision Loop

### The Agent Cycle

Agents don't just produce one output and stop. They work in a continuous loop:

```
┌─────────────────────────────────────────────────────────┐
│                  AGENT DECISION LOOP                    │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │   1. OBSERVE            │
              │   "What's the current   │
              │    situation?"          │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │   2. REASON             │
              │   "What should I do?"   │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │   3. ACT                │
              │   "Do it"               │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │   4. EVALUATE           │
              │   "Did it work?"        │
              └─────────────────────────┘
                            │
                            └──────► BACK TO OBSERVE
```

### Example: A Security Agent Reviewing a Design

Let's trace this loop:

```
OBSERVE:
  The agent reads the design document.
  "I see the system uses JWT tokens"

REASON:
  "JWT tokens should have expiration times"
  "I should check if this is specified"

ACT:
  The agent queries its knowledge about JWT best practices
  It checks the document for expiration settings

EVALUATE:
  "No expiration mentioned - this is a vulnerability"
  "I should report this finding"

OBSERVE:
  The agent moves to the next section of the document
  "Now I see the database schema..."
```

### Why This Matters for Architecture Reviews

In our system, each agent goes through this loop many times while reviewing a document:

```
1. Read a section of the design
2. Think about potential issues
3. Note any problems found
4. Move to the next section
5. Connect findings across sections
6. Produce a comprehensive report
```

---

## P1.4 Types of Agents Used in Our System

### The Five Specialists

Our system uses five specialized agents, each with a different focus:

```
┌─────────────────────────────────────────────────────────┐
│              ARCHITECTURE REVIEW AGENTS                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ FUNCTIONAL AGENT                               │   │
│  │ Checks if requirements are complete            │   │
│  │ Ensures domain boundaries are clear            │   │
│  │ Validates user journeys                        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ SECURITY AGENT                                 │   │
│  │ Finds vulnerabilities                          │   │
│  │ Checks OWASP compliance                        │   │
│  │ Reviews authentication/authorization           │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ DATA AGENT                                     │   │
│  │ Reviews database design                        │   │
│  │ Checks normalization                           │   │
│  │ Validates data lifecycle                       │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ DEVOPS AGENT                                   │   │
│  │ Reviews CI/CD pipeline                         │   │
│  │ Checks containerization                        │   │
│  │ Validates monitoring setup                     │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ RELIABILITY AGENT                              │   │
│  │ Reviews performance requirements               │   │
│  │ Checks fault tolerance                         │   │
│  │ Validates observability                        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Why Specialized Agents?

Think of it like a hospital:

| General Doctor | Medical Specialists |
|----------------|-------------------|
| One doctor for everything | Cardiologist, Neurologist, Orthopedic... |
| Good for general issues | Expert in specific areas |
| Might miss rare conditions | Catches domain-specific problems |

Our specialized agents:
- **Catch more issues**: Each is an expert in their domain
- **Provide better recommendations**: Specific, actionable advice
- **Are more consistent**: Follow a structured checklist
- **Cover all bases**: No domain is overlooked

---

## P1.5 How Agents Learn: Prompt Engineering

### What is Prompt Engineering?

**Prompt engineering** is the art of giving AI agents the right instructions to get the best results. It's like giving clear directions to someone who wants to help you.

### The Anatomy of a Good Prompt

```
┌─────────────────────────────────────────────────────────┐
│                  GOOD PROMPT                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. ROLE                                               │
│     "You are a Security Architect..."                   │
│                                                         │
│  2. GOAL                                               │
│     "Find vulnerabilities in this design..."            │
│                                                         │
│  3. CONTEXT                                            │
│     "The system uses JWT authentication..."             │
│                                                         │
│  4. CHECKLIST                                          │
│     "Check: OWASP Top 10, STRIDE threats..."           │
│                                                         │
│  5. FORMAT                                             │
│     "Return JSON with: findings, severity..."          │
│                                                         │
│  6. EXAMPLES                                           │
│     "Good finding: 'Missing CSRF token on /payments'"  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Example: A Prompt for the Security Agent

Here's an actual prompt from our system:

```python
system_prompt = f"""You are the Security Architecture Agent, a specialist 
in reviewing software design documents for security vulnerabilities 
and best practices.

Your role is to ensure that:
1. OWASP Top 10 vulnerabilities are addressed
2. STRIDE threat modeling has been performed
3. No hardcoded secrets exist
4. Authentication and authorization are properly designed
5. Data encryption is implemented correctly

You must evaluate the design against this validation checklist:

{self.matrix.to_prompt()}

For each check, determine:
- PASS: The check is satisfied with evidence
- FAIL: The check is not satisfied
- PARTIAL: Partially satisfied but needs improvement

Your response must be structured as JSON with:
- summary: Overall security assessment
- findings: List of vulnerabilities or issues found
- severity: CRITICAL/HIGH/MEDIUM/LOW
- evidence: Quote from the document
- recommendation: Specific action to address the issue
- overall_risk: LOW/MEDIUM/HIGH
"""
```

### Why Prompts Matter

The difference between a good and bad prompt is huge:

| Bad Prompt | Good Prompt |
|------------|-------------|
| "Review this document" | "You are a Security Architect. Find OWASP Top 10 vulnerabilities. Provide specific evidence and recommendations." |
| Unstructured response | JSON format with specific fields |
| Generic advice | Actionable recommendations |
| Misses issues | Structured checklist ensures coverage |

---

## P1.6 How Agents Work Together: Orchestration

### What is Orchestration?

**Orchestration** is the coordination of multiple agents to achieve a complex goal. Think of a symphony orchestra:

```
┌─────────────────────────────────────────────────────────┐
│                 ORCHESTRATION                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  CONDUCTOR = Orchestrator                               │
│  Directs all agents                                     │
│  Ensures they work together                             │
│  Handles timing and flow                               │
│                                                         │
│  VIOLINISTS = Functional Agent                         │
│  FLUTISTS = Security Agent                             │
│  CELLISTS = Data Agent                                 │
│  TIMPANI = DevOps Agent                                │
│  HORNS = Reliability Agent                             │
│                                                         │
│  RESULT = Beautiful symphony (Complete Review)          │
└─────────────────────────────────────────────────────────┘
```

### How Our System Orchestrates Agents

Our system uses two main orchestration frameworks:

**1. LangGraph - The Conductor**

LangGraph defines the workflow and manages the flow:

```
START
  │
  ▼
INITIALIZE
  │
  ▼
FUNCTIONAL AGENT → Checks requirements
  │
  ▼
SECURITY AGENT → Finds vulnerabilities
  │
  ▼
DATA AGENT → Reviews schema
  │
  ▼
DEVOPS AGENT → Checks CI/CD
  │
  ▼
RELIABILITY AGENT → Reviews performance
  │
  ▼
AGGREGATE RESULTS → Combine findings
  │
  ▼
HUMAN REVIEW GATE → Pause for approval
  │
  ▼
GENERATE REPORT → Create final output
  │
  ▼
END
```

**2. CrewAI - The Documentation Team**

CrewAI creates a specialized team for documentation:

```
WRITER →
  "I'll create the first draft of the review report"
  
EDITOR →
  "I'll polish the writing and fix errors"
  
REVIEWER →
  "I'll ensure completeness and accuracy"
  
FORMATTER →
  "I'll format it as a proper ADR"
```

---

## P1.7 Agents in Action: A Complete Example

### Walkthrough: Reviewing a Payment System Design

Let's trace what happens when you run a review:

**Step 1: You submit a design document**

```bash
python review.py review -d docs/payment-system.md
```

**Step 2: The Orchestrator starts**

```
Orchestrator: "Starting review of payment-system.md"
Orchestrator: "Reading document..."
Orchestrator: "Document loaded (1,234 lines)"
```

**Step 3: Each agent does its part**

```
Functional Agent:
  "Reading requirements section..."
  "Checking user stories..."
  "Found: Missing failed payment handling"
  "Recommendation: Add user story for payment failures"

Security Agent:
  "Checking authentication..."
  "Checking encryption..."
  "Found: No rate limiting on login endpoint"
  "Severity: HIGH"
  "Recommendation: Implement rate limiting with Redis"

Data Agent:
  "Checking database schema..."
  "Checking relationships..."
  "Found: No audit table for payment changes"
  "Recommendation: Create audit_log table"

DevOps Agent:
  "Checking deployment strategy..."
  "Found: No health check endpoint"
  "Recommendation: Add /health endpoint"

Reliability Agent:
  "Checking performance requirements..."
  "Found: No load testing mentioned"
  "Recommendation: Add load testing to CI/CD"
```

**Step 4: Results are aggregated**

```
Orchestrator: "All agents complete"
Orchestrator: "Aggregating findings..."
Aggregate Score: 72%
Overall Risk: MEDIUM
Total Findings: 12
Critical: 2
High: 4
```

**Step 5: Human review gate**

```
Orchestrator: "Pausing for human review..."
========== HUMAN REVIEW GATE ==========
Review ID: review_20260803_143022
Score: 72%
Risk: MEDIUM
Findings: 12

Critical Findings:
  SECURITY: No rate limiting on login endpoint
  SECURITY: No encryption at rest for PII

Options:
  1. APPROVE - Proceed with report
  2. REJECT - Stop the review
  3. RETRY - Re-run the agents

Enter choice (1/2/3): 1
Comments: "Approve, but track security issues"

Orchestrator: "Human approved - generating final report..."
```

**Step 6: Final output generated**

```
Orchestrator: "Report generated!"
Orchestrator: "ADR generated!"
Orchestrator: "Review complete."

Generated files:
  - docs/outputs/review_20260803_143022_report.txt
  - docs/adrs/adr-0002-payment-system-review.md
  - docs/outputs/review_20260803_143022.json
```

---

## P1.8 Common Questions About AI Agents

### Q: Are agents actually "intelligent"?

No, not in the way humans are. AI agents:
- Don't truly understand
- Don't have consciousness
- Don't have genuine emotions
- Can't reason creatively

They're very good at pattern recognition and following instructions.

### Q: Can agents make mistakes?

Yes! Common issues:
- **Hallucinations**: Making up facts
- **Bias**: Reflecting biases in training data
- **Context loss**: Forgetting earlier parts of the conversation
- **Overconfidence**: Being wrong but confident

That's why we have human review gates!

### Q: How much do agents cost?

Costs depend on:
- **Model**: GPT-4 is more expensive than GPT-3.5
- **Length**: Longer documents cost more
- **Number of agents**: More agents = more API calls

Typical costs:
```
Single agent, GPT-3.5: ~$0.002
Multi-agent (5 agents), GPT-4: ~$0.20
```

### Q: Can I trust agent recommendations?

Our system builds trust through:
1. **Evidence**: Agents provide evidence from the document
2. **Checklists**: Structured, repeatable checks
3. **Multiple agents**: Consensus across specialists
4. **Human review**: Final approval required
5. **Audit trail**: All actions are logged

### Q: How do I become better at working with agents?

1. **Learn to write good prompts**: Clear, specific instructions
2. **Understand their limitations**: They're tools, not replacements
3. **Validate outputs**: Always review what agents produce
4. **Iterate**: Improve prompts based on what works
5. **Monitor**: Watch costs and quality

---

## P1.9 Key Takeaways

### What You've Learned

1. **AI Agents** are programs that perceive, reason, act, and learn
2. **Agents have components**: Brain (LLM), Memory, Tools, Goals
3. **Agents work in a loop**: Observe → Reason → Act → Evaluate
4. **Specialized agents** catch more issues than general ones
5. **Prompt engineering** is the key to getting good results
6. **Orchestration** coordinates multiple agents working together
7. **Human oversight** is essential for quality and trust

### Why This Matters for Architecture Reviews

Our system uses all these concepts to:
- **Catch more issues**: 5 specialists instead of 1 generalist
- **Be consistent**: Follow structured checklists
- **Save time**: Automate repetitive reviews
- **Provide evidence**: Every finding has evidence
- **Create documentation**: Automatic ADR generation

### Next Steps

Now that you understand AI agents, you're ready to:
- Use the review system effectively
- Customize agent prompts
- Add new specialized agents
- Understand how the system works

*Need more? The next primer covers Architecture Design Reviews - what makes a good review and why multi-agent reviews are superior.*
