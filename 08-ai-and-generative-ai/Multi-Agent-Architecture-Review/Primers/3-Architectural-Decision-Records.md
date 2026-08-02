# Primer 3: Architectural Decision Records (ADRs) - A Beginner's Guide

## P3.1 What is an Architectural Decision Record (ADR)?

### The Concept

An **Architectural Decision Record (ADR)** is a formal document that captures an important architectural decision and its context. It's like a legal contract for your architecture—it records what was decided, why it was decided, and what the consequences are.

### A Real-World Analogy

Imagine a company making a major strategic decision:

```
STRATEGIC DECISION: Open a new office in London

Why record this decision?
1. Future employees will know WHY we opened in London
2. We can evaluate if it was the right decision
3. If it fails, we learn from the process
4. New leadership understands the reasoning
5. Prevents revisiting the same debate

ARCHITECTURE DECISION: Use PostgreSQL for the payment service

Why record this decision?
1. Future developers will know WHY PostgreSQL was chosen
2. We can evaluate if it's still the right choice
3. If it causes problems, we learn from it
4. New team members understand the reasoning
5. Prevents revisiting the database debate
```

### Why ADRs Matter

```
┌─────────────────────────────────────────────────────────┐
│              WHY ADRs ARE IMPORTANT                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. DOCUMENTATION                                       │
│     "Why did we choose this approach?"                 │
│     ADRs provide the answer                             │
│                                                         │
│  2. CONTEXT                                             │
│     "What were we thinking at the time?"               │
│     ADRs capture the context                            │
│                                                         │
│  3. EDUCATION                                           │
│     "How do we make decisions?"                        │
│     ADRs teach the process                              │
│                                                         │
│  4. EVOLUTION                                           │
│     "When should we reconsider?"                       │
│     ADRs track decisions over time                      │
│                                                         │
│  5. ACCOUNTABILITY                                      │
│     "Who made this decision and why?"                  │
│     ADRs provide traceability                           │
└─────────────────────────────────────────────────────────┘
```

---

## P3.2 The Structure of an ADR

### The MADR Format

We use the **MADR (Markdown Architectural Decision Records)** format. It's clean, readable, and version-control friendly.

```
┌─────────────────────────────────────────────────────────┐
│              ADR STRUCTURE (MADR Format)                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  # ADR {NUMBER}: {TITLE}                               │
│                                                         │
│  ## Status                                              │
│  PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED        │
│                                                         │
│  ## Date                                                │
│  YYYY-MM-DD                                            │
│                                                         │
│  ## Context                                             │
│  What is the situation?                                │
│  What are the constraints?                             │
│  What forces are at play?                              │
│                                                         │
│  ## Decision                                            │
│  What was decided?                                     │
│  What is the change?                                   │
│                                                         │
│  ## Rationale                                           │
│  Why was this decision made?                           │
│  What are the benefits?                                │
│                                                         │
│  ## Consequences                                        │
│  What are the positive consequences?                   │
│  What are the negative consequences?                   │
│  What are the mitigations?                             │
│                                                         │
│  ## Alternatives Considered                             │
│  What other options were evaluated?                    │
│  Why were they rejected?                               │
│                                                         │
│  ## References                                          │
│  Links to related documents                            │
│  Links to other ADRs                                   │
│                                                         │
│  ## Reviewers                                           │
│  Who reviewed this decision?                           │
└─────────────────────────────────────────────────────────┘
```

### Example: A Real ADR from Our System

```markdown
# ADR 0001: Adopt Multi-Agent Orchestration Framework for Architecture Reviews

## Status
Accepted

## Date
2026-08-03

## Context
Our engineering teams need to perform comprehensive architecture reviews on 
design documents before implementation. Currently, reviews are performed by 
individual architects, leading to:

1. **Domain Blind Spots:** Individual architects cannot be experts in all 
   domains (security, data, DevOps, performance, functional).
2. **Inconsistent Coverage:** Reviews vary significantly based on the 
   architect's background and daily focus.
3. **No Audit Trail:** Decisions are not formally documented, making it hard 
   to understand past decisions or hold reviews accountable.
4. **Scalability Issues:** As our team grows, the number of design documents 
   increases, but our architecture review capacity doesn't scale linearly.

## Decision
We will implement our architecture review system using **Multi-Model 
Orchestration Frameworks**, specifically:

1. **LangGraph** for orchestrating the review workflow with human-in-the-loop 
   gates
2. **CrewAI** for role-based documentation generation
3. **Custom Python** for repository integration and ADR generation

## Rationale
1. **Enterprise Governance:** We need formal ADRs, audit logs, and approval 
   workflows. Orchestration frameworks provide these out of the box.
2. **Complete Control:** We need to customize agent behaviors, prompts, and 
   workflows. Orchestration frameworks are open and extensible.
3. **Repository Integration:** True codebase awareness requires reading actual 
   files, not copy-pasted content.
4. **Extensibility:** As our needs evolve, we can add new agents, tools, and 
   workflows without rewriting the system.

## Consequences
### Positive
- ✅ Comprehensive reviews covering all quality domains
- ✅ Formal ADRs generated for every review
- ✅ Audit trail for compliance and debugging
- ✅ Scalable review capacity

### Negative
- ❌ Increased complexity in setup and maintenance
- ❌ Higher initial infrastructure investment
- ❌ Longer review time due to multi-agent coordination
- ❌ Requires API budget for multiple LLM calls

### Mitigations
- Use caching to reduce costs
- Implement budget controls
- Use cost-effective models for non-critical tasks
- Document everything thoroughly

## Alternatives Considered
### Native Agent Teams (Claude Code)
Considered using Claude Code subagents. Rejected because of vendor lock-in 
and limited customization.

### Conversational LLM Persona Simulation
Considered using ChatGPT with role-playing prompts. Rejected because of 
inconsistent results and no governance.

## References
- [Architecture Decision Records (MADR)](https://adr.github.io/madr/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [CrewAI Documentation](https://docs.crewai.com/)

## Reviewers
- Sarah Chen, Principal Software Engineer
- Mike Johnson, Engineering Manager
- Priya Patel, Security Architect
```

---

## P3.3 Why ADRs Are Important for Our System

### ADRs as the Final Output

In our system, ADRs are the ultimate deliverable. They represent the consensus of all five specialized agents and the human reviewer:

```
┌─────────────────────────────────────────────────────────┐
│              ADR GENERATION FLOW                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  FUNCTIONAL AGENT ────┐                                │
│  SECURITY AGENT ──────┤                                │
│  DATA AGENT ──────────┤──► AGGREGATION ──► ADR        │
│  DEVOPS AGENT ────────┤                                │
│  RELIABILITY AGENT ───┘                                │
│                                                         │
│  HUMAN REVIEW GATE ───────────────────────────────────►│
│                                                         │
│  RESULT: Formal ADR ready for repository commit        │
└─────────────────────────────────────────────────────────┘
```

### What Our ADRs Contain

Our system automatically generates ADRs that include:

**1. Decision Status**

Based on review results:

| Conditions | Status |
|------------|--------|
| Score ≥ 85%, Critical = 0 | APPROVED |
| Score 70-84%, Critical ≤ 2 | CONDITIONALLY APPROVED |
| Score < 70%, Critical ≥ 3 | REJECTED |

**2. Context**

Captures the review context:
- What was reviewed
- When it was reviewed
- Who reviewed it
- What the key findings were

**3. Decision**

Clear statement of the decision:
- Approved: Proceed with implementation
- Conditionally Approved: Proceed after fixing issues
- Rejected: Redesign or major changes needed

**4. Rationale**

Why the decision was made:
- Based on agent findings
- Based on human review
- Based on risk assessment

**5. Consequences**

What this decision means:
- Positive: What we gain
- Negative: What we lose
- Mitigations: How we handle risks

---

## P3.4 How Our System Generates ADRs

### The ADR Generation Process

```
STEP 1: EXTRACT FINDINGS
  ┌─────────────────────────────────────┐
  │ From all agent results:             │
  │ - Critical issues (blockers)        │
  │ - High issues (important)           │
  │ - Recommendations (actionable)      │
  └─────────────────────────────────────┘
                    │
                    ▼
STEP 2: DETERMINE STATUS
  ┌─────────────────────────────────────┐
  │ Based on:                           │
  │ - Aggregate score                   │
  │ - Overall risk                      │
  │ - Critical findings count           │
  │ - Human approval status             │
  └─────────────────────────────────────┘
                    │
                    ▼
STEP 3: BUILD CONTEXT
  ┌─────────────────────────────────────┐
  │ Include:                            │
  │ - Review ID                         │
  │ - Document name                     │
  │ - Agent scores                      │
  │ - Key findings                      │
  │ - Risk assessment                   │
  └─────────────────────────────────────┘
                    │
                    ▼
STEP 4: FORMAT ADR
  ┌─────────────────────────────────────┐
  │ Use MADR template:                  │
  │ - Title with ADR number             │
  │ - Status                            │
  │ - Date                              │
  │ - Context                           │
  │ - Decision                          │
  │ - Rationale                         │
  │ - Consequences                      │
  │ - Alternatives considered           │
  │ - References                        │
  └─────────────────────────────────────┘
                    │
                    ▼
STEP 5: SAVE TO REPOSITORY
  ┌─────────────────────────────────────┐
  │ - docs/adrs/adr-{number}-{slug}.md │
  │ - Ready for commit                  │
  │ - Part of audit trail               │
  └─────────────────────────────────────┘
```

### Example: From Review to ADR

**Agent Findings:**
```
Functional Agent: 88% - "Missing failed payment handling"
Security Agent: 62% - "No rate limiting, missing encryption"
Data Agent: 78% - "No audit table for payments"
DevOps Agent: 82% - "Missing health check endpoint"
Reliability Agent: 70% - "No load testing plan"

Aggregate: 76% - MEDIUM risk
Critical findings: 2 (Security)
```

**Generated ADR:**
```markdown
# ADR 0002: Payment Service Architecture Review

## Status
CONDITIONALLY APPROVED

## Date
2026-08-03

## Context
The payment service design was reviewed by five specialized agents:
- Functional: 88% - Requirements mostly complete
- Security: 62% - Critical issues found
- Data: 78% - Schema needs audit capability
- DevOps: 82% - Deployment plan solid
- Reliability: 70% - Performance concerns

## Decision
The design is conditionally approved. Security issues must be fixed before 
implementation begins.

## Rationale
- Functional and DevOps are strong (✅)
- Data model needs minor improvements (⚠️)
- Security has critical vulnerabilities (❌)
- Human review approved with conditions

## Consequences
### Positive
- The design is fundamentally sound
- Most domains are well covered
- Clear path forward

### Negative
- Implementation delayed until security fixes
- Additional work required for data audit

## Critical Issues to Fix
1. Add rate limiting on login endpoint
2. Implement encryption at rest for PII

## High Priority Issues
3. Add audit table for payment changes
4. Implement load testing in CI/CD

## Alternatives Considered
- Full rejection was considered but rejected as design is fundamentally sound
- Security issues are fixable without redesign

## References
- Review ID: review_20260803_143022
- Full Review Report: docs/outputs/review_20260803_143022_report.txt
- Security Standards: PCI DSS compliance required
```

---

## P3.5 ADR Lifecycle

### The ADR Journey

```
┌─────────────────────────────────────────────────────────┐
│              ADR LIFECYCLE                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. PROPOSED                                            │
│     "We're considering this decision"                  │
│     - ADR created                                     │
│     - Status: PROPOSED                                │
│     - Review requested                                 │
│                                                         │
│  2. IN REVIEW                                           │
│     "We're evaluating this decision"                    │
│     - Being reviewed by agents                         │
│     - Status: IN REVIEW                                │
│     - Feedback being collected                         │
│                                                         │
│  3. ACCEPTED                                            │
│     "We've approved this decision"                     │
│     - Review complete                                  │
│     - Status: ACCEPTED                                 │
│     - Implementation can begin                         │
│                                                         │
│  4. DEPRECATED                                          │
│     "We're moving away from this decision"             │
│     - Status: DEPRECATED                               │
│     - New ADR references this one                      │
│                                                         │
│  5. SUPERSEDED                                          │
│     "This decision has been replaced"                  │
│     - Status: SUPERSEDED                               │
│     - New ADR replaces this one                        │
└─────────────────────────────────────────────────────────┘
```

### Managing ADRs Over Time

**Initial Decision:**
```
ADR 0001: Use PostgreSQL
Status: ACCEPTED
```

**Later, a better option emerges:**
```
ADR 0005: Migrate to CockroachDB

Rationale: "PostgreSQL is now a bottleneck for global scaling"

Status: PROPOSED

Referenced:
  - Supersedes: ADR 0001 (Use PostgreSQL)
```

**Result:**
```
ADR 0001: Use PostgreSQL
Status: SUPERSEDED
Superseded by: ADR 0005

ADR 0005: Migrate to CockroachDB
Status: ACCEPTED
Supersedes: ADR 0001
```

---

## P3.6 Using ADRs Effectively

### Best Practices

**DO's:**

✅ Write ADRs early in the decision process
✅ Keep ADRs focused on one decision
✅ Use clear, unambiguous language
✅ Include the "why" not just the "what"
✅ Link related ADRs
✅ Review ADRs regularly
✅ Update statuses as decisions evolve

**DON'Ts:**

❌ Write ADRs for every tiny decision
❌ Let ADRs become outdated
❌ Use ADRs as a replacement for documentation
❌ Forget to link related ADRs
❌ Ignore ADRs after they're written

### ADR Review Checklist

```
□ Is the decision clearly stated?
□ Is the context described?
□ Are the consequences documented?
□ Are alternatives considered?
□ Are references included?
□ Is the status current?
□ Is the format consistent?
□ Would a new team member understand it?
□ Could it be misused or misunderstood?
□ When should this decision be revisited?
```

---

## P3.7 Common ADR Mistakes

### What to Avoid

**1. Too Vague**

```
BAD: "We decided to use a database."

GOOD: "We decided to use PostgreSQL 15 for the payment service because 
      of its ACID compliance and strong community support."
```

**2. No Context**

```
BAD: "We use Redis for caching."

GOOD: "We use Redis for session caching because we need sub-millisecond 
      latency and Redis supports TTL-based expiration."
```

**3. No Alternatives**

```
BAD: "We chose Kubernetes."

GOOD: "We chose Kubernetes over ECS because it provides better vendor 
      lock-in avoidance and has a larger ecosystem for open-source tools."
```

**4. No Consequences**

```
BAD: "We implemented microservices."

GOOD: "We implemented microservices. This increases operational complexity 
      but improves team autonomy and deployment independence. Mitigations 
      include standardized observability and centralized service discovery."
```

**5. Too Long**

```
BAD: (A 20-page ADR with every detail)

GOOD: (A 2-3 page ADR focusing on the decision, context, and consequences)
```

---

## P3.8 The Value of Automated ADR Generation

### Manual vs. Automated ADRs

| Aspect | Manual ADRs | Automated ADRs |
|--------|-------------|----------------|
| **Time** | Hours to write | Minutes to generate |
| **Consistency** | Varies by author | Always consistent |
| **Completeness** | Depends on author | Always complete |
| **Evidence** | May lack evidence | Always includes evidence |
| **Review** | Requires separate process | Built into review |
| **Updates** | Often forgotten | Automatic with changes |
| **Audit Trail** | Partial | Complete |

### Why Automation Works

Our system generates ADRs automatically because:

1. **The review process already captures all the information**
2. **The structure is well-defined (MADR format)**
3. **The decision is clear from the review outcome**
4. **The evidence is in the agent findings**
5. **The human review provides final approval**

### Example: Efficiency Comparison

```
MANUAL ADR WRITING:
1. Write the decision (15 mins)
2. Write the context (10 mins)
3. Write the rationale (15 mins)
4. Write consequences (10 mins)
5. List alternatives (10 mins)
6. Add references (5 mins)
7. Review and edit (15 mins)
Total: ~80 minutes

AUTOMATED ADR GENERATION:
1. Run the review (2 minutes)
2. Generate ADR (5 seconds)
3. Review and approve (2 minutes)
Total: ~4 minutes

TIME SAVED: 76 minutes per ADR
```

---

## P3.9 Key Takeaways

### What You've Learned

1. **ADRs** document important architectural decisions
2. **The MADR format** is the recommended structure
3. **ADRs include**: Status, Date, Context, Decision, Rationale, Consequences
4. **ADRs have a lifecycle**: Proposed → In Review → Accepted → Deprecated/Superseded
5. **Our system generates ADRs automatically** from review results
6. **ADRs provide**: Documentation, Context, Education, Evolution, Accountability
7. **Automation saves time** and ensures consistency
8. **ADRs are living documents** that evolve over time

### Why This Matters

```
ADRs are the foundation of effective architecture governance:

1. They capture WHY decisions were made
2. They provide evidence for future discussions
3. They educate new team members
4. They prevent revisiting old debates
5. They create a permanent decision log
6. They enable better decision-making

OUR SYSTEM MAKES ADR GENERATION:
- Automatic: No manual effort required
- Consistent: Same format every time
- Evidence-based: Based on actual findings
- Review-ready: Already approved by human gate
- Actionable: Clear next steps
```

### What You Can Do Now

- Read existing ADRs in your organization
- Understand the MADR format
- Appreciate the value of automated ADRs
- Use our system to generate ADRs
- Maintain ADRs over time
- Link ADRs to decisions
- Use ADRs for project documentation

