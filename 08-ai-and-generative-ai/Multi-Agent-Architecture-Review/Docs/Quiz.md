# Multi-Agent AI Architecture Review System
# Comprehensive Quiz & Test Bank

---

## OVERVIEW

This test bank contains **150+ questions** organized by:
- **Level**: Beginner, Intermediate, Advanced
- **Type**: Multiple Choice, True/False, Fill-in-the-Blank, Short Answer, Practical
- **Section**: Corresponding to the 4 parts of the series

**Answer Keys**: Provided at the end of each section.

---

## SECTION 1: FOUNDATIONS & TECHNICAL LANDSCAPE
### Level 1: Beginner (10 Questions)

---

**1.1 Multiple Choice**

**Q1:** What is the primary problem that multi-agent architecture reviews solve?
- A) Writing code faster
- B) Replacing human architects
- C) Single-architect blind spots and limited domain coverage
- D) Reducing the number of design documents

**Answer: C**

---

**Q2:** Which of the following is NOT listed as a blind spot of single-architect reviews?
- A) Domain specialization
- B) Attention decay
- C) Unlimited working memory
- D) Confirmation bias

**Answer: C**

---

**Q3:** What are the three primary technical paradigms for AI-assisted architecture reviews?
- A) Native Agent Teams, Persona Simulation, Orchestration Frameworks
- B) ChatGPT, Gemini, Claude
- C) Python, Java, C++
- D) Agile, Waterfall, Scrum

**Answer: A**

---

**Q4:** Which paradigm provides the best governance and audit trail capabilities?
- A) Native Developer Agent Teams
- B) Conversational LLM Persona Simulation
- C) Multi-Model Orchestration Frameworks
- D) All are equally good

**Answer: C**

---

**Q5:** What does ADR stand for?
- A) Advanced Design Review
- B) Architectural Decision Record
- C) Automated Document Retrieval
- D) Agent Development Runtime

**Answer: B**

---

**1.2 True/False**

**Q6:** Single-architect reviews consistently catch all security vulnerabilities.

**Answer: False**

---

**Q7:** Conversational LLM Persona Simulation requires no code to implement.

**Answer: True**

---

**Q8:** Multi-Model Orchestration Frameworks are the easiest option to set up.

**Answer: False**

---

**Q9:** Repository awareness means the system can read files from your codebase.

**Answer: True**

---

**Q10:** An ADR documents what decision was made and why.

**Answer: True**

---

## SECTION 1: FOUNDATIONS & TECHNICAL LANDSCAPE
### Level 2: Intermediate (10 Questions)

---

**1.3 Multiple Choice**

**Q11:** What is the estimated cost for a single-agent review using GPT-4?
- A) ~$0.002
- B) ~$0.04
- C) ~$0.24
- D) ~$5.00

**Answer: B**

---

**Q12:** Which framework is used for orchestrating the review workflow with human-in-the-loop gates in our system?
- A) CrewAI
- B) AutoGen
- C) LangGraph
- D) MetaGPT

**Answer: C**

---

**Q13:** What is the purpose of the `.env` file in the project?
- A) To store environment variables and API keys
- B) To configure Python paths
- C) To define the project structure
- D) To document the architecture

**Answer: A**

---

**Q14:** Which of the following is NOT a component of the BaseAgent class?
- A) `review()` method
- B) `get_prompt()` method
- C) `_call_llm()` method
- D) `generate_report()` method

**Answer: D**

---

**Q15:** What is the default model used in the configuration?
- A) gpt-3.5-turbo
- B) gpt-4-turbo-preview
- C) claude-3-opus-20240229
- D) deepseek-chat

**Answer: B**

---

**1.4 Fill-in-the-Blank**

**Q16:** The ________ method in the BaseAgent is responsible for calling the LLM with cost tracking.

**Answer:** `_call_llm()`

---

**Q17:** To activate the virtual environment on macOS/Linux, you run: `source ________/bin/activate`

**Answer:** venv

---

**Q18:** The decision to use orchestration frameworks is documented in ADR ________.

**Answer:** 0001

---

**Q19:** The ________ tool is used for structured logging throughout the application.

**Answer:** structlog

---

**Q20:** The review budget is set by the environment variable ________.

**Answer:** REVIEW_BUDGET_USD

---

## SECTION 1: FOUNDATIONS & TECHNICAL LANDSCAPE
### Level 3: Advanced (10 Questions)

---

**1.5 Multiple Choice**

**Q21:** What is the purpose of the `@abstractmethod` decorator in the BaseAgent class?
- A) To prevent the class from being instantiated
- B) To enforce that subclasses implement specific methods
- C) To optimize performance
- D) To enable logging

**Answer: B**

---

**Q22:** Which of the following is NOT a valid reason for choosing Orchestration Frameworks over Native Agent Teams?
- A) Vendor independence
- B) Complete control over agent behavior
- C) Simpler setup process
- D) Built-in governance

**Answer: C**

---

**Q23:** What is the role of Pydantic in the configuration system?
- A) To parse YAML files
- B) To provide type validation for settings
- C) To manage database connections
- D) To create the CLI interface

**Answer: B**

---

**Q24:** How does the CostTracker persist cost data between runs?
- A) It stores data in a SQLite database
- B) It writes to a JSON file in the logs directory
- C) It sends data to an external API
- D) It only keeps data in memory

**Answer: B**

---

**Q25:** Which provider is supported as a fallback when OpenAI is not available?
- A) Google Gemini
- B) Anthropic Claude
- C) Microsoft Azure
- D) Amazon Bedrock

**Answer: B**

---

**1.6 Short Answer**

**Q26:** Explain the difference between `temperature` and `max_tokens` in the context of LLM configuration.

**Answer:**
- **Temperature** controls the randomness/creativity of the output. Lower values (0.1-0.3) produce more deterministic, focused responses, while higher values (0.7-1.0) produce more creative, diverse responses.
- **Max_tokens** limits the length of the response, controlling how many tokens the model can generate.

---

**Q27:** Why is it important to use a virtual environment for the project?

**Answer:**
Virtual environments provide isolation for project dependencies, preventing conflicts between different projects' package versions. They allow the project to run with exactly the required versions of libraries regardless of what's installed system-wide.

---

**Q28:** Describe the purpose of the `get_settings()` function in the configuration module.

**Answer:**
The `get_settings()` function implements a singleton pattern that returns a single, globally accessible settings instance. This ensures consistent configuration across the application and avoids reloading environment variables multiple times.

---

**Q29:** How does the BaseAgent support multiple LLM providers (OpenAI, Anthropic, DeepSeek)?

**Answer:**
The BaseAgent's `_init_llm_client()` method checks the model name and initializes the appropriate client. For OpenAI and DeepSeek (which uses OpenAI-compatible API), it creates an OpenAI client. For Anthropic, it creates an Anthropic client. The `_call_llm()` method then uses the appropriate API format.

---

**Q30:** What are the three key decision drivers that led to choosing Orchestration Frameworks?

**Answer:**
1. **Repository Awareness**: The ability to read actual codebase files, not just design documents
2. **Domain Specialization**: Support for multiple specialized agents covering different quality domains
3. **Governance**: Built-in ADR generation, audit trails, human-in-the-loop gates, and permissions management

---

### Section 1 Answer Key Summary

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | C | 16 | `_call_llm()` |
| 2 | C | 17 | venv |
| 3 | A | 18 | 0001 |
| 4 | C | 19 | structlog |
| 5 | B | 20 | REVIEW_BUDGET_USD |
| 6 | False | 21 | B |
| 7 | True | 22 | C |
| 8 | False | 23 | B |
| 9 | True | 24 | B |
| 10 | True | 25 | B |
| 11 | B | 26 | See above |
| 12 | C | 27 | See above |
| 13 | A | 28 | See above |
| 14 | D | 29 | See above |
| 15 | B | 30 | See above |

---

## SECTION 2: DOMAIN SPECIALIZATION
### Level 1: Beginner (10 Questions)

---

**2.1 Multiple Choice**

**Q31:** How many specialized agents are there in the system?
- A) 3
- B) 4
- C) 5
- D) 6

**Answer: C**

---

**Q32:** Which domain does the Functional Agent focus on?
- A) Security vulnerabilities
- B) Requirements completeness and domain boundaries
- C) Database schema design
- D) Deployment and operations

**Answer: B**

---

**Q33:** What is the name of the Security Agent's validation methodology that includes Spoofing, Tampering, and Repudiation?
- A) OWASP
- B) STRIDE
- C) DREAD
- D) CVSS

**Answer: B**

---

**Q34:** Which agent reviews database normalization and data lifecycle?
- A) DevOps Agent
- B) Reliability Agent
- C) Data Agent
- D) Functional Agent

**Answer: C**

---

**Q35:** What are the priority levels used in validation matrices?
- A) Low, Medium, High
- B) Critical, High, Medium, Low
- C) P0, P1, P2, P3
- D) Blocking, Major, Minor, Trivial

**Answer: B**

---

**2.2 True/False**

**Q36:** The DevOps Agent reviews OWASP compliance.

**Answer: False (Security Agent does this)**

---

**Q37:** The Reliability Agent reviews caching strategies and fault tolerance.

**Answer: True**

---

**Q38:** Each agent uses a different output format for its findings.

**Answer: False (All use JSON format)**

---

**Q39:** The validation matrix includes examples of violations and suggestions for fixes.

**Answer: True**

---

**Q40:** The Functional Agent only checks if the code compiles.

**Answer: False**

---

## SECTION 2: DOMAIN SPECIALIZATION
### Level 2: Intermediate (10 Questions)

---

**2.3 Multiple Choice**

**Q41:** Which method in the BaseAgent must be overridden by specialized agents?
- A) `_call_llm()`
- B) `_init_llm_client()`
- C) `review()`
- D) `__init__()`

**Answer: C**

---

**Q42:** What is the primary purpose of the validation matrix?
- A) To define the agent's persona
- B) To provide a structured checklist for the agent
- C) To store API keys
- D) To format the output

**Answer: B**

---

**Q43:** Which agent focuses on monitoring, alerting, and cost optimization?
- A) Security Agent
- B) Data Agent
- C) DevOps Agent
- D) Reliability Agent

**Answer: C**

---

**Q44:** What is the recommended database normalization target according to the Data Agent?
- A) 1NF
- B) 2NF
- C) 3NF
- D) BCNF

**Answer: C**

---

**Q45:** In the Security Agent, what severity level is assigned to hardcoded credentials?
- A) HIGH
- B) MEDIUM
- C) CRITICAL
- D) LOW

**Answer: C**

---

**2.4 Fill-in-the-Blank**

**Q46:** The ________ matrix defines the checks for each domain agent.

**Answer:** validation

---

**Q47:** The Reliability Agent reviews ________, which includes metrics, logs, and traces.

**Answer:** observability

---

**Q48:** The Security Agent's validation includes STRIDE: Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, and ________ of Privilege.

**Answer:** Elevation

---

**Q49:** The Data Agent checks for proper ________ to ensure data integrity.

**Answer:** normalization

---

**Q50:** The DevOps Agent reviews Infrastructure as ________ (IaC).

**Answer:** Code

---

## SECTION 2: DOMAIN SPECIALIZATION
### Level 3: Advanced (10 Questions)

---

**2.5 Multiple Choice**

**Q51:** What is the formula for calculating the agent's score in the review method?
```python
# Which formula is used?
passed = sum(1 for f in findings if f.get('status') == 'PASS')
score = ________
```
- A) `(passed / total) * 100`
- B) `(total / passed) * 100`
- C) `passed * 100 / total`
- D) Both A and C are correct

**Answer: D**

---

**Q52:** How does the Security Agent calculate its score differently from other agents?
- A) It uses severity weights
- B) It only counts critical findings
- C) It doesn't calculate a score
- D) It uses a different formula

**Answer: A**

---

**Q53:** What is the purpose of the `DomainMatrix.to_prompt()` method?
- A) To convert the matrix to a JSON format
- B) To generate a prompt-friendly string of the validation checklist
- C) To save the matrix to disk
- D) To validate the matrix structure

**Answer: B**

---

**Q54:** Which agent would check for "No health check endpoint"?
- A) Functional Agent
- B) Security Agent
- C) DevOps Agent
- D) Reliability Agent

**Answer: C**

---

**Q55:** What is the correct inheritance hierarchy for a specialized agent?
- A) `FunctionalAgent → BaseAgent`
- B) `BaseAgent → FunctionalAgent`
- C) `FunctionalAgent → DomainMatrix`
- D) `DomainMatrix → FunctionalAgent`

**Answer: B**

---

**2.6 Short Answer**

**Q56:** Explain why the Security Agent uses a lower temperature setting (0.1) compared to other agents.

**Answer:**
Security reviews require consistency and precision. A lower temperature produces more deterministic, predictable responses, reducing the chance of hallucination or inconsistent findings. Security issues are critical and need reliable detection, not creative interpretation.

---

**Q57:** Describe the process of creating a new domain agent, from class creation to integration.

**Answer:**
1. Create a new class inheriting from `BaseAgent`
2. Implement the `__init__` method, calling `super()` and initializing the domain matrix
3. Implement `get_prompt()` with domain-specific instructions and the validation matrix
4. Implement `review()` to call the LLM and parse the JSON response
5. Add the new agent to `__init__.py` exports
6. Add the agent to the orchestrator's agent dictionary
7. Add the validation matrix to `VALIDATION_MATRICES`

---

**Q58:** What is the significance of the `evidence` field in agent findings?

**Answer:**
The `evidence` field provides a direct quote or reference from the document that justifies the finding. This is crucial for:
- Transparency: Anyone can verify the finding
- Accountability: The agent's reasoning is documented
- Trust: Users can see the basis for recommendations
- Actionability: Developers know exactly what part of the document to fix

---

**Q59:** Why does the Reliability Agent check for both caching strategies and fault tolerance?

**Answer:**
Caching and fault tolerance are both critical for system reliability:
- **Caching** improves performance and reduces load, preventing failures due to overload
- **Fault tolerance** ensures the system continues working when components fail
Together, they address both the proactive (performance) and reactive (recovery) aspects of reliability.

---

**Q60:** Compare and contrast the DevOps Agent and the Reliability Agent in terms of their focus areas.

**Answer:**
**DevOps Agent** focuses on operational aspects:
- CI/CD pipeline
- Containerization
- Infrastructure as Code
- Monitoring and alerting
- Cost optimization
- Disaster recovery

**Reliability Agent** focuses on system behavior:
- Observability (logs, metrics, traces)
- Caching strategy
- Fault tolerance
- Performance requirements
- Rate limiting
- Graceful degradation

While both deal with operations, DevOps is about how the system is deployed and managed, while Reliability is about how the system performs and recovers during runtime.

---

### Section 2 Answer Key Summary

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 31 | C | 46 | validation |
| 32 | B | 47 | observability |
| 33 | B | 48 | Elevation |
| 34 | C | 49 | normalization |
| 35 | B | 50 | Code |
| 36 | False | 51 | D |
| 37 | True | 52 | A |
| 38 | False | 53 | B |
| 39 | True | 54 | C |
| 40 | False | 55 | B |
| 41 | C | 56 | See above |
| 42 | B | 57 | See above |
| 43 | C | 58 | See above |
| 44 | C | 59 | See above |
| 45 | C | 60 | See above |

---

## SECTION 3: FRAMEWORK SELECTION & ORCHESTRATION
### Level 1: Beginner (10 Questions)

---

**3.1 Multiple Choice**

**Q61:** Which framework is used as the primary orchestrator in our system?
- A) CrewAI
- B) AutoGen
- C) LangGraph
- D) OpenAI Swarm

**Answer: C**

---

**Q62:** What is the purpose of orchestration?
- A) To write code faster
- B) To coordinate multiple agents in a structured workflow
- C) To replace human architects
- D) To generate documentation

**Answer: B**

---

**Q63:** Which framework is used for the documentation team?
- A) LangGraph
- B) CrewAI
- C) AutoGen
- D) MetaGPT

**Answer: B**

---

**Q64:** What is a human-in-the-loop gate?
- A) A hardware component
- B) A pause in the workflow for human approval
- C) A type of agent
- D) A logging mechanism

**Answer: B**

---

**Q65:** How many agents are in the CrewAI documentation team?
- A) 2
- B) 3
- C) 4
- D) 5

**Answer: C** (Writer, Editor, Reviewer, Formatter)

---

**3.2 True/False**

**Q66:** LangGraph uses state graphs for workflow management.

**Answer: True**

---

**Q67:** CrewAI agents cannot communicate with each other.

**Answer: False**

---

**Q68:** Checkpointing allows you to resume a workflow after a failure.

**Answer: True**

---

**Q69:** The human review gate is optional and can be skipped.

**Answer: True (with auto-approve flag)**

---

**Q70:** LangGraph stores checkpoints in memory only.

**Answer: False**

---

## SECTION 3: FRAMEWORK SELECTION & ORCHESTRATION
### Level 2: Intermediate (10 Questions)

---

**3.3 Multiple Choice**

**Q71:** What is the role of the `ReviewState` TypedDict in LangGraph?
- A) To store the agent's memory
- B) To define the structure of the state flowing through the graph
- C) To configure the LLM
- D) To log errors

**Answer: B**

---

**Q72:** Which process is used in the CrewAI team?
- A) Parallel
- B) Sequential
- C) Hierarchical
- D) Random

**Answer: B**

---

**Q73:** What is the purpose of the `interrupt_after` parameter in LangGraph compilation?
- A) To stop the graph execution
- B) To pause execution after specific nodes for human intervention
- C) To log the execution time
- D) To restart the graph

**Answer: B**

---

**Q74:** Which component is NOT part of the CrewAI agent definition?
- A) role
- B) goal
- C) backstory
- D) temperature

**Answer: D** (temperature is set on the LLM, not the agent)

---

**Q75:** What is the purpose of the `configurable` parameter with `thread_id` in LangGraph?
- A) To configure the LLM
- B) To set the model temperature
- C) To identify a specific workflow instance for checkpointing
- D) To enable debugging

**Answer: C**

---

**3.4 Fill-in-the-Blank**

**Q76:** The ________ is the conductor that directs all agents and ensures they work together.

**Answer:** orchestrator

---

**Q77:** In LangGraph, nodes represent ________, and edges represent ________ between nodes.

**Answer:** actions, transitions

---

**Q78:** The CrewAI ________ agent creates the initial documentation draft.

**Answer:** Writer

---

**Q79:** The ________ agent in CrewAI ensures documentation is complete and accurate.

**Answer:** Reviewer

---

**Q80:** LangGraph checkpoints are stored in ________ when using SQLite persistence.

**Answer:** SQLite

---

## SECTION 3: FRAMEWORK SELECTION & ORCHESTRATION
### Level 3: Advanced (10 Questions)

---

**3.5 Multiple Choice**

**Q81:** In LangGraph, what is the correct way to add a conditional edge after the human review node?
```python
workflow.add_conditional_edges(
    "human_review",
    ________,
    {"approved": "report", "rejected": END}
)
```
- A) `after_human_review`
- B) `_after_human_review`
- C) `after_human_review()`
- D) `_after_human_review()`

**Answer: B** (the function name without parentheses)

---

**Q82:** What does the CrewAI `Process` enum specify?
- A) The model to use
- B) How agents collaborate (sequential, hierarchical, etc.)
- C) The output format
- D) The token budget

**Answer: B**

---

**Q83:** Which of the following is NOT a feature of LangGraph's checkpointing?
- A) Resume from failure
- B) Save state at each node
- C) Share checkpoints across machines
- D) Human-in-the-loop interruption

**Answer: C**

---

**Q84:** What is the purpose of the `crew.kickoff()` method?
- A) To start the CrewAI team execution
- B) To stop the execution
- C) To configure the agents
- D) To save the output

**Answer: A**

---

**Q85:** How does the Unified Orchestrator combine LangGraph and CrewAI?
- A) They run in parallel
- B) LangGraph runs first, then CrewAI generates documentation
- C) CrewAI runs first, then LangGraph reviews
- D) They run independently

**Answer: B**

---

**3.6 Short Answer**

**Q86:** Explain the difference between LangGraph's `invoke()` and `stream()` methods.

**Answer:**
- `invoke()` runs the graph to completion and returns the final state in one call
- `stream()` yields intermediate states as the graph executes, allowing real-time progress updates

---

**Q87:** Describe the advantages of using SQLite for checkpointing versus MemorySaver.

**Answer:**
- **SQLite**: Persists checkpoints to disk, survives process restarts, can be shared across processes, supports larger workflows
- **MemorySaver**: Faster, but loses checkpoints when the process exits, limited to a single process

---

**Q88:** Why does CrewAI use roles and backstories in agent definitions?

**Answer:**
Roles and backstories provide context that improves the agent's performance by:
- Defining the agent's expertise and authority
- Setting expectations for the response style
- Creating a consistent persona that guides behavior
- Making the agent's outputs more natural and appropriate to the role

---

**Q89:** What is the significance of the `StateGraph` class in LangGraph?

**Answer:**
`StateGraph` defines the structure of the workflow. It:
- Holds the state type definition
- Manages nodes (actions)
- Defines edges (transitions)
- Enables conditional branching
- Provides the framework for checkpointing

---

**Q90:** Describe the complete flow of the Unified Orchestrator from start to finish.

**Answer:**
1. **Initialization**: Loads configuration and initializes agents
2. **LangGraph Review**: Runs the review workflow with all five specialized agents
3. **Aggregation**: Combines agent findings and calculates overall metrics
4. **Human Review Gate**: Pauses for human approval (if enabled)
5. **CrewAI Documentation**: Generates documentation using the Writer → Editor → Reviewer → Formatter team
6. **Output Generation**: Saves the report, ADR, and JSON results
7. **Completion**: Returns the complete results to the user

---

### Section 3 Answer Key Summary

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 61 | C | 76 | orchestrator |
| 62 | B | 77 | actions, transitions |
| 63 | B | 78 | Writer |
| 64 | B | 79 | Reviewer |
| 65 | C | 80 | SQLite |
| 66 | True | 81 | B |
| 67 | False | 82 | B |
| 68 | True | 83 | C |
| 69 | True | 84 | A |
| 70 | False | 85 | B |
| 71 | B | 86 | See above |
| 72 | B | 87 | See above |
| 73 | B | 88 | See above |
| 74 | D | 89 | See above |
| 75 | C | 90 | See above |

---

## SECTION 4: PRODUCTION GOVERNANCE
### Level 1: Beginner (10 Questions)

---

**4.1 Multiple Choice**

**Q91:** What does RAG stand for?
- A) Repository Analysis Gateway
- B) Retrieval-Augmented Generation
- C) Review and Assessment Group
- D) Response Action Guide

**Answer: B**

---

**Q92:** Which component scans the Git repository for relevant files?
- A) RAGContext
- B) RepositoryScanner
- C) ADRGenerator
- D) PermissionManager

**Answer: B**

---

**Q93:** What format does the ADRGenerator use for ADRs?
- A) JSON
- B) YAML
- C) MADR (Markdown)
- D) XML

**Answer: C**

---

**Q94:** What is the purpose of sandboxing?
- A) To make the system faster
- B) To restrict agent operations for security
- C) To improve the quality of reviews
- D) To reduce costs

**Answer: B**

---

**Q95:** Where are audit logs stored?
- A) In the database
- B) In logs/audit.json
- C) In the cloud
- D) In memory only

**Answer: B**

---

**4.2 True/False**

**Q96:** ADRs are automatically generated from review results.

**Answer: True**

---

**Q97:** The RepositoryScanner can only read Markdown files.

**Answer: False**

---

**Q98:** RAG uses semantic search to find relevant content in the repository.

**Answer: True**

---

**Q99:** All agents have the same permissions regardless of their role.

**Answer: False**

---

**Q100:** Audit logs are only created when an error occurs.

**Answer: False**

---

## SECTION 4: PRODUCTION GOVERNANCE
### Level 2: Intermediate (10 Questions)

---

**4.3 Multiple Choice**

**Q101:** Which embedding model is used for RAG by default?
- A) all-MiniLM-L6-v2
- B) text-embedding-ada-002
- C) sentence-transformers
- D) BERT-base

**Answer: A**

---

**Q102:** What is the purpose of the `Permission` enum?
- A) To define the agents
- B) To define allowed actions for agents
- C) To set the model permissions
- D) To configure the API

**Answer: B**

---

**Q103:** Which agent role has the most permissions in the default configuration?
- A) review_agent
- B) security_agent
- C) documentation_agent
- D) admin

**Answer: D**

---

**Q104:** What does the `is_path_allowed()` method in `SandboxedExecutor` check?
- A) If the path exists
- B) If the path is within the allowed workspace
- C) If the path is readable
- D) If the path is writable

**Answer: B**

---

**Q105:** Which format does the ADRGenerator use for status?
- A) PASS/FAIL
- B) APPROVED/CONDITIONALLY APPROVED/REJECTED
- C) TRUE/FALSE
- D) LOW/MEDIUM/HIGH

**Answer: B**

---

**4.4 Fill-in-the-Blank**

**Q106:** The ________ method in the ADRGenerator determines the ADR status based on review results.

**Answer:** `_determine_status()`

---

**Q107:** The RAG system uses ________ to convert text into vectors for semantic search.

**Answer:** embeddings

---

**Q108:** The ________ file stores the audit log for compliance purposes.

**Answer:** audit.json

---

**Q109:** The SandboxedExecutor restricts file operations to the ________ directory.

**Answer:** workspace

---

**Q110:** The ADRGenerator uses the ________ format for architectural decisions.

**Answer:** MADR

---

## SECTION 4: PRODUCTION GOVERNANCE
### Level 3: Advanced (10 Questions)

---

**4.5 Multiple Choice**

**Q111:** What is the purpose of the `hash` field in the file info extracted by the RepositoryScanner?
- A) To store the file content
- B) To detect changes in the file
- C) To encrypt the file
- D) To identify the file type

**Answer: B**

---

**Q112:** How does the RAGContext handle embedding caching?
- A) It caches only in memory
- B) It uses a JSON cache file with content hashes
- C) It never caches embeddings
- D) It uses Redis for caching

**Answer: B**

---

**Q113:** Which SQLite implementation is used for LangGraph checkpointing?
- A) MemorySaver
- B) SqliteSaver
- C) PostgresSaver
- D) FileSystemSaver

**Answer: B**

---

**Q114:** What is the maximum file size allowed by the SandboxedExecutor?
- A) 1MB
- B) 5MB
- C) 10MB
- D) 100MB

**Answer: C** (10MB limit in the code)

---

**Q115:** How does the PermissionManager determine if an action is permitted?
- A) It checks the agent's role against a permissions map
- B) It asks the user for approval
- C) It uses a machine learning model
- D) It allows all actions by default

**Answer: A**

---

**4.6 Short Answer**

**Q116:** Explain the process of generating an ADR from review results, step by step.

**Answer:**
1. **Extract Findings**: Parse all agent results for critical and high-priority issues
2. **Determine Status**: Evaluate the aggregate score, risk level, and critical findings count
3. **Build Decision Section**: Format the decision statement based on the status
4. **Construct Context**: Include review metadata, scores, and finding counts
5. **Add Consequences**: Document positive and negative consequences
6. **Generate MD**: Format in MADR specification
7. **Save File**: Write to `docs/adrs/adr-{number}-{slug}.md`
8. **Return Metadata**: Return the ADR number, filepath, and content

---

**Q117:** Compare the roles of the RepositoryScanner and RAGContext.

**Answer:**
- **RepositoryScanner**: Performs initial scanning of the repository, detecting file types, extracting content, and building a basic structure. It's the "eyes" of the system.
- **RAGContext**: Builds on the scanner's output, generating embeddings for semantic search, caching them, and providing retrieval capabilities. It's the "memory" that enables intelligent search.

**Relationship**: RAGContext uses RepositoryScanner to get files, then enhances them with embeddings for semantic retrieval.

---

**Q118:** What are the security benefits of using permissions and sandboxing?

**Answer:**
**Permissions (Role-Based Access Control)**:
- Prevents agents from performing unauthorized actions
- Limits access based on the principle of least privilege
- Ensures compliance with security policies

**Sandboxing**:
- Restricts file access to the workspace directory
- Limits file size to prevent DoS attacks
- Prevents system file modification
- Contains potential security breaches

**Combined**: Provides defense in depth, ensuring even if an agent is compromised, the damage is limited.

---

**Q119:** Explain the MADR format and why it was chosen for ADRs.

**Answer:**
**MADR (Markdown Architectural Decision Records)** is a lightweight format for documenting architectural decisions. It includes:
- Status, Date, Context, Decision, Rationale, Consequences, Alternatives, References

**Why chosen**:
- **Simple**: Uses Markdown, which is version-control friendly
- **Complete**: Captures all essential decision information
- **Standardized**: Known format understood by architects
- **Auditable**: Clear structure for compliance
- **Extensible**: Can be adapted for specific needs

---

**Q120:** Design a new permission for the system. What would it be called, what would it allow, and which agent would need it?

**Answer:**

**New Permission**: `READ_PERFORMANCE_METRICS`

**What it allows**: Access to performance monitoring data and system health metrics

**Which agent needs it**: The Reliability Agent, to correlate design decisions with actual system performance

**Why**: Allows the Reliability Agent to compare design performance targets with actual production metrics, providing more accurate and context-aware recommendations

**Implementation**:
```python
class Permission(Enum):
    # ... existing permissions ...
    READ_PERFORMANCE_METRICS = "read_performance_metrics"

ROLE_PERMISSIONS = {
    'reliability_agent': {
        # ... existing permissions ...
        Permission.READ_PERFORMANCE_METRICS,
    }
}
```

---

### Section 4 Answer Key Summary

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 91 | B | 106 | `_determine_status()` |
| 92 | B | 107 | embeddings |
| 93 | C | 108 | audit.json |
| 94 | B | 109 | workspace |
| 95 | B | 110 | MADR |
| 96 | True | 111 | B |
| 97 | False | 112 | B |
| 98 | True | 113 | B |
| 99 | False | 114 | C |
| 100 | False | 115 | A |
| 101 | A | 116 | See above |
| 102 | B | 117 | See above |
| 103 | D | 118 | See above |
| 104 | B | 119 | See above |
| 105 | B | 120 | See above |

---

## PRACTICAL EXERCISES

---

### Exercise 1: Create a New Agent (Intermediate)

**Instructions:**
Create a new Compliance Agent that checks for GDPR compliance in design documents.

**Requirements:**
1. Inherit from BaseAgent
2. Create a validation matrix with at least 4 compliance checks
3. Implement `get_prompt()` with appropriate instructions
4. Implement `review()` to parse the response and calculate a score

**Expected Output:**
- The agent should return a dictionary with:
  - `domain`: "compliance"
  - `agent`: "ComplianceAgent"
  - `findings`: List of compliance issues
  - `score`: 0-100
  - `overall_risk`: LOW/MEDIUM/HIGH

**Sample Solution:**

```python
from typing import Dict, Any, List
import json
from .base_agent import BaseAgent
from src.prompts.validation_matrix import DomainMatrix

class ComplianceAgent(BaseAgent):
    def __init__(self, model: str = None):
        super().__init__("ComplianceAgent", model)
        self.matrix = self._create_validation_matrix()
        self.logger.info("ComplianceAgent initialized")
    
    def _create_validation_matrix(self) -> DomainMatrix:
        checks = [
            {
                "id": "COMP-001",
                "description": "GDPR data protection requirements are addressed",
                "priority": "critical",
                "examples": ["No data processing agreement", "Missing data subject rights"],
                "suggestions": "Document GDPR compliance measures"
            },
            {
                "id": "COMP-002",
                "description": "Data retention and deletion policies are defined",
                "priority": "high",
                "examples": ["No retention period", "Missing deletion procedures"],
                "suggestions": "Define data retention and deletion policies"
            },
            {
                "id": "COMP-003",
                "description": "Privacy by design principles are followed",
                "priority": "medium",
                "examples": ["No data minimization", "Missing privacy impact assessment"],
                "suggestions": "Implement privacy by design principles"
            },
            {
                "id": "COMP-004",
                "description": "Data breach notification procedures are defined",
                "priority": "high",
                "examples": ["No breach notification timeline", "Missing regulatory reporting"],
                "suggestions": "Define 72-hour breach notification procedures"
            }
        ]
        return DomainMatrix("Compliance", checks)
    
    def get_prompt(self, document: str) -> List[Dict[str, str]]:
        system_prompt = f"""You are the Compliance Architecture Agent, a specialist in reviewing software design documents for regulatory compliance.

Your role is to ensure that:
1. GDPR data protection requirements are addressed
2. Data retention and deletion policies are defined
3. Privacy by design principles are followed
4. Data breach notification procedures are defined

Validation checklist:
{self.matrix.to_prompt()}

Return your analysis as JSON with:
- summary: Overall compliance assessment
- findings: List of compliance issues
- overall_risk: LOW/MEDIUM/HIGH
- score: 0-100
- recommendation: Overall compliance recommendation
"""
        
        user_prompt = f"""
Review this design document for compliance concerns:

{document}
"""
        
        return [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
    
    def review(self, document: str) -> Dict[str, Any]:
        self.logger.info("Starting compliance review")
        
        messages = self.get_prompt(document)
        response = self._call_llm(messages)
        
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
            else:
                result = json.loads(response)
            
            result['domain'] = 'compliance'
            result['agent'] = self.name
            result['model'] = self.model
            
            # Calculate score
            findings = result.get('findings', [])
            if findings:
                passed = sum(1 for f in findings if f.get('status') == 'PASS')
                score = (passed / len(findings)) * 100
            else:
                score = 100
            
            result['score'] = round(score, 1)
            
            self.logger.info(f"Compliance review complete. Score: {score:.1f}%")
            return result
            
        except json.JSONDecodeError as e:
            self.logger.error(f"Failed to parse response: {e}")
            return {
                'domain': 'compliance',
                'agent': self.name,
                'model': self.model,
                'summary': 'Error parsing LLM response',
                'error': str(e),
                'findings': [],
                'score': 0,
                'overall_risk': 'HIGH'
            }
```

---

### Exercise 2: Extend the Orchestrator (Advanced)

**Instructions:**
Modify the SimpleOrchestrator to include the new ComplianceAgent.

**Requirements:**
1. Import the ComplianceAgent
2. Add it to the agents dictionary
3. Update the logging to mention the new agent count
4. Update the report generation to include compliance results

**Expected Output:**
- Orchestrator should run with 6 agents (5 original + Compliance)
- Report should include compliance findings

**Sample Solution:**

```python
# In src/orchestration/simple_orchestrator.py

# Add import
from src.agents.compliance_agent import ComplianceAgent

class SimpleOrchestrator:
    def __init__(self, model: Optional[str] = None):
        self.model = model
        self.logger = get_logger("simple_orchestrator")
        self.cost_tracker = get_cost_tracker()
        
        # Initialize all agents including the new one
        self.agents = {
            'functional': FunctionalAgent(model),
            'security': SecurityAgent(model),
            'data': DataAgent(model),
            'devops': DevOpsAgent(model),
            'reliability': ReliabilityAgent(model),
            'compliance': ComplianceAgent(model),  # New agent
        }
        
        self.logger.info(f"Orchestrator initialized with {len(self.agents)} agents")
    
    # ... rest of the code remains the same ...
    
    def generate_report(self, results: Dict[str, Any]) -> str:
        # ... existing code ...
        
        # Update the agent results section to handle 6 agents
        for name, result in results.get('results', {}).items():
            lines.append(f"=== {name.upper()} ===")
            # ... rest unchanged ...
```

---

### Exercise 3: ADR Customization (Intermediate)

**Instructions:**
Customize the ADRGenerator to add a new section for "Compliance Considerations".

**Requirements:**
1. Add a new method to extract compliance findings
2. Add a new section to the ADR content
3. Include compliance status in the summary

**Sample Solution:**

```python
# In src/governance/adr_generator.py

class ADRGenerator:
    def _extract_compliance_findings(self, review_results: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extract compliance findings from review results."""
        results = review_results.get('results', {})
        compliance_result = results.get('compliance', {})
        
        if not compliance_result:
            return []
        
        findings = compliance_result.get('findings', [])
        return [f for f in findings if f.get('status') != 'PASS']
    
    def _build_adr_content(self, **kwargs) -> str:
        # ... existing code ...
        
        # Add Compliance Considerations section
        if kwargs.get('compliance_findings'):
            lines.append("## Compliance Considerations")
            lines.append("")
            for finding in kwargs['compliance_findings'][:3]:
                severity = finding.get('severity', 'MEDIUM')
                rec = finding.get('recommendation', '')
                lines.append(f"- **{severity}**: {rec[:100]}...")
            lines.append("")
        
        # ... rest of the code ...
```

---

## FINAL COMPREHENSIVE EXAM

---

### Part A: Multiple Choice (25 Questions)

**1.** Which of the following is the primary advantage of multi-agent architecture reviews over single-agent reviews?
- A) Faster review times
- B) Lower cost
- C) Comprehensive coverage across all domains
- D) Simpler implementation

**Answer: C**

---

**2.** What is the correct order of the agent decision loop?
- A) Act → Observe → Reason → Evaluate
- B) Observe → Reason → Act → Evaluate
- C) Evaluate → Act → Reason → Observe
- D) Reason → Observe → Act → Evaluate

**Answer: B**

---

**3.** Which framework is used for the documentation team in the Unified Orchestrator?
- A) LangGraph
- B) CrewAI
- C) AutoGen
- D) OpenAI Swarm

**Answer: B**

---

**4.** What does STRIDE stand for in security threat modeling?
- A) Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege
- B) Security, Testing, Risk, Integration, Deployment, Evaluation
- C) System, Threat, Response, Investigation, Detection, Enforcement
- D) Structure, Trade-offs, Resilience, Integrity, Design, Efficiency

**Answer: A**

---

**5.** Which agent checks for CI/CD readiness and containerization?
- A) Functional Agent
- B) Security Agent
- C) Data Agent
- D) DevOps Agent

**Answer: D**

---

**6.** What is the purpose of checkpointing in LangGraph?
- A) To speed up execution
- B) To save workflow state for resuming after failures
- C) To reduce costs
- D) To improve agent accuracy

**Answer: B**

---

**7.** Which method in the BaseAgent must be implemented by specialized agents?
- A) `_call_llm()`
- B) `_init_llm_client()`
- C) `review()`
- D) `get_settings()`

**Answer: C**

---

**8.** What is the recommended maximum file size for the SandboxedExecutor?
- A) 1MB
- B) 5MB
- C) 10MB
- D) 100MB

**Answer: C**

---

**9.** Which component provides semantic search over the repository?
- A) RepositoryScanner
- B) RAGContext
- C) ADRGenerator
- D) PermissionManager

**Answer: B**

---

**10.** What format does the ADRGenerator use for ADRs?
- A) JSON
- B) XML
- C) MADR
- D) YAML

**Answer: C**

---

**11.** Which agent would review observability (metrics, logs, traces)?
- A) DevOps Agent
- B) Reliability Agent
- C) Data Agent
- D) Functional Agent

**Answer: B**

---

**12.** What is the purpose of the `human_approval` field in the LangGraph state?
- A) To store the user's name
- B) To indicate whether a human has approved the review
- C) To track the number of approvals
- D) To store the approval timestamp

**Answer: B**

---

**13.** How does the CostTracker persist cost data?
- A) In a SQLite database
- B) In a JSON file
- C) In memory only
- D) In a text file

**Answer: B**

---

**14.** Which of the following is NOT a CrewAI agent role in the documentation team?
- A) Writer
- B) Editor
- C) Reviewer
- D) Tester

**Answer: D**

---

**15.** What is the purpose of the `interrupt_after` parameter in LangGraph?
- A) To stop execution after the specified node
- B) To pause for human intervention after the specified node
- C) To restart the workflow
- D) To log the execution time

**Answer: B**

---

**16.** Which permission allows an agent to generate ADRs?
- A) READ_DESIGN_DOCS
- B) GENERATE_ADR
- C) WRITE_LOGS
- D) MAKE_API_CALLS

**Answer: B**

---

**17.** What is the default embedding model used for RAG?
- A) text-embedding-ada-002
- B) all-MiniLM-L6-v2
- C) BERT-base
- D) sentence-transformers/all-mpnet-base-v2

**Answer: B**

---

**18.** Which agent checks for OWASP Top 10 vulnerabilities?
- A) Functional Agent
- B) Security Agent
- C) Data Agent
- D) DevOps Agent

**Answer: B**

---

**19.** What is the purpose of the `configuration` method in the CLI?
- A) To run the review
- B) To display the current configuration
- C) To generate an ADR
- D) To scan the repository

**Answer: B**

---

**20.** Which of the following is a critical validation check in the Security Agent?
- A) "API contracts are versioned"
- B) "No hardcoded secrets"
- C) "Backup and recovery procedures"
- D) "Caching strategy"

**Answer: B**

---

**21.** What is the purpose of the `_save_cache()` method in RAGContext?
- A) To save the embeddings to disk for reuse
- B) To save the document content
- C) To save the API responses
- D) To save the configuration

**Answer: A**

---

**22.** Which of the following is NOT a component of the ADR structure?
- A) Status
- B) Context
- C) Code Implementation
- D) Consequences

**Answer: C**

---

**23.** What does the `batch_size` parameter in the batch processing function control?
- A) The number of tokens per batch
- B) The number of files processed at once
- C) The number of agents per batch
- D) The number of API calls per batch

**Answer: B**

---

**24.** Which method in the PermissionManager checks if an agent has a specific permission?
- A) `check_permission()`
- B) `has_permission()`
- C) `validate_permission()`
- D) `verify_permission()`

**Answer: B**

---

**25.** What is the recommended approach for handling rate limit errors?
- A) Stop the workflow
- B) Retry with exponential backoff
- C) Ignore the error
- D) Switch to a different provider

**Answer: B**

---

### Part B: True/False (15 Questions)

**26.** Single-agent reviews are more comprehensive than multi-agent reviews.

**Answer: False**

---

**27.** The temperature parameter controls the randomness of the LLM output.

**Answer: True**

---

**28.** CrewAI is used for the main review workflow orchestration.

**Answer: False** (LangGraph is used for orchestration)

---

**29.** Checkpointing allows resuming a workflow after a failure.

**Answer: True**

---

**30.** The DevOps Agent reviews security vulnerabilities.

**Answer: False** (Security Agent does this)

---

**31.** ADRs are generated manually by architects.

**Answer: False** (Generated automatically by the system)

---

**32.** RAG provides context to agents by searching the repository.

**Answer: True**

---

**33.** All agents have the same permissions by default.

**Answer: False**

---

**34.** Audit logs are stored in the database.

**Answer: False** (Stored in JSON file)

---

**35.** The Reliability Agent reviews caching strategies.

**Answer: True**

---

**36.** LangGraph checkpoints are stored only in memory.

**Answer: False** (Can be stored in SQLite)

---

**37.** The MADR format is used for ADRs.

**Answer: True**

---

**38.** The Data Agent checks for proper database normalization.

**Answer: True**

---

**39.** The SandboxedExecutor allows file operations outside the workspace.

**Answer: False**

---

**40.** The CLI provides commands for auditing and cost tracking.

**Answer: True**

---

### Part C: Short Answer (5 Questions)

**41.** Explain the difference between a general AI and an AI agent.

**Answer:**
A general AI responds to prompts but doesn't take initiative, has no memory, and provides one-shot responses. An AI agent perceives its environment, reasons about what to do, takes action to achieve a goal, and learns from feedback. Agents have memory, use tools, and work in a decision loop (Observe → Reason → Act → Evaluate). Agents are proactive and autonomous, while general AIs are reactive.

---

**42.** Describe the process of aggregating results from the five specialized agents.

**Answer:**
Aggregation involves:
1. **Calculate aggregate score**: Average all agent scores
2. **Determine overall risk**: Take the highest risk level among all agents
3. **Count total findings**: Sum findings from all agents
4. **Count critical/high findings**: Sum critical and high severity findings
5. **Generate unified summary**: Combine agent summaries into a single assessment
6. **Produce final output**: Create a unified report with all aggregated metrics

---

**43.** Why is RAG important for architecture reviews, and how does it improve agent performance?

**Answer:**
RAG (Retrieval-Augmented Generation) improves agent performance by:
- **Context**: Providing agents with relevant context from the entire codebase, not just the design document
- **Evidence**: Enabling agents to reference existing code patterns and ADRs
- **Accuracy**: Reducing hallucinations by grounding responses in actual repository content
- **Relevance**: Making recommendations more specific to the existing codebase
- **Consistency**: Ensuring new decisions align with existing patterns

---

**44.** Explain the purpose and structure of the validation matrix.

**Answer:**
The validation matrix provides a structured checklist for each domain agent. It includes:
- **Check ID**: Unique identifier for each check
- **Description**: What the check verifies
- **Priority**: Critical/High/Medium/Low
- **Examples**: Common violations
- **Suggestions**: How to address the issue

The matrix ensures agents cover all critical aspects of their domain consistently, making reviews repeatable and comprehensive.

---

**45.** How does the permission system protect the system from unauthorized actions?

**Answer:**
The permission system uses role-based access control (RBAC) to:
- **Restrict Operations**: Each agent can only perform actions explicitly permitted for its role
- **Sandbox Actions**: File operations are restricted to the workspace directory
- **Audit All Attempts**: Every action attempt is logged, regardless of success
- **Limit Resources**: File size and operation scope are limited
- **Defense in Depth**: Multiple layers of protection (permissions + sandboxing + auditing) prevent unauthorized actions

---

### Part D: Practical Implementation (2 Questions)

**46.** Write the code for a new Domain Matrix for a "Performance" agent that checks for load testing, capacity planning, and performance monitoring. Include at least 4 checks with appropriate priorities.

**Answer:**

```python
def get_performance_matrix() -> DomainMatrix:
    """Performance domain validation matrix."""
    checks = [
        {
            "id": "PERF-001",
            "description": "Load testing is planned and documented",
            "priority": "critical",
            "examples": ["No load test plan", "Missing performance benchmarks"],
            "suggestions": "Design load tests with specific performance targets"
        },
        {
            "id": "PERF-002",
            "description": "Capacity planning is documented",
            "priority": "high",
            "examples": ["No growth projections", "Missing scale-out strategy"],
            "suggestions": "Project growth over 12-24 months, plan capacity accordingly"
        },
        {
            "id": "PERF-003",
            "description": "Performance monitoring is configured",
            "priority": "high",
            "examples": ["No metrics defined", "Missing alerting thresholds"],
            "suggestions": "Define key performance metrics and alerting"
        },
        {
            "id": "PERF-004",
            "description": "Performance requirements are measurable",
            "priority": "medium",
            "examples": ["Vague performance claims", "No SLOs defined"],
            "suggestions": "Define specific SLOs with measurable SLIs"
        },
        {
            "id": "PERF-005",
            "description": "Caching strategy is performance-optimized",
            "priority": "medium",
            "examples": ["No cache invalidation plan", "Missing cache hit rate targets"],
            "suggestions": "Define cache strategy with hit rate targets"
        }
    ]
    return DomainMatrix("Performance", checks)

# Add to VALIDATION_MATRICES
VALIDATION_MATRICES = {
    # ... existing matrices ...
    "performance": get_performance_matrix(),
}
```

---

**47.** Write a complete implementation of a new CLI command that generates a summary report from saved review results.

**Answer:**

```python
# In src/cli.py

@cli.command()
@click.option(
    '--review-file',
    '-r',
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help='Path to the review results JSON file'
)
@click.option(
    '--output',
    '-o',
    type=click.Path(path_type=Path),
    default='docs/outputs/summary.md',
    help='Output file for the summary'
)
@click.option(
    '--verbose',
    '-v',
    is_flag=True,
    help='Enable verbose output'
)
def summary(review_file: Path, output: Path, verbose: bool):
    """Generate a summary report from saved review results."""
    console.print(f"[bold]Generating summary from: {review_file.name}[/bold]")
    
    try:
        # Load review results
        with open(review_file, 'r') as f:
            results = json.load(f)
        
        # Extract key information
        summary_lines = []
        summary_lines.append("# Architecture Review Summary")
        summary_lines.append("")
        summary_lines.append(f"**Review ID:** {results.get('review_id', 'N/A')}")
        summary_lines.append(f"**Timestamp:** {results.get('timestamp', 'N/A')}")
        summary_lines.append(f"**Aggregate Score:** {results.get('aggregated_score', 0)}%")
        summary_lines.append(f"**Overall Risk:** {results.get('overall_risk', 'UNKNOWN')}")
        summary_lines.append(f"**Total Findings:** {results.get('total_findings', 0)}")
        summary_lines.append(f"**Critical Findings:** {results.get('critical_findings', 0)}")
        summary_lines.append(f"**High Findings:** {results.get('high_findings', 0)}")
        summary_lines.append("")
        summary_lines.append("## Agent Results")
        summary_lines.append("")
        
        # Agent results table
        summary_lines.append("| Agent | Score | Risk | Findings |")
        summary_lines.append("|-------|-------|------|----------|")
        
        for name, result in results.get('results', {}).items():
            score = result.get('score', 0)
            risk = result.get('overall_risk', 'UNKNOWN')
            findings = len(result.get('findings', []))
            summary_lines.append(f"| {name.upper()} | {score}% | {risk} | {findings} |")
        
        summary_lines.append("")
        summary_lines.append("## Critical Findings")
        summary_lines.append("")
        
        # Critical findings
        critical_count = 0
        for name, result in results.get('results', {}).items():
            findings = result.get('findings', [])
            critical = [f for f in findings if f.get('severity', '').upper() == 'CRITICAL']
            if critical:
                summary_lines.append(f"### {name.upper()}")
                for f in critical:
                    summary_lines.append(f"- **{f.get('check_id', 'N/A')}**: {f.get('recommendation', 'No recommendation')}")
                summary_lines.append("")
                critical_count += len(critical)
        
        if critical_count == 0:
            summary_lines.append("✅ No critical findings reported.")
        
        summary_lines.append("")
        summary_lines.append("## Recommendations")
        summary_lines.append("")
        
        # Collect recommendations
        recommendations = []
        for name, result in results.get('results', {}).items():
            if result.get('recommendation'):
                recommendations.append(f"- **{name.upper()}**: {result['recommendation']}")
        
        if recommendations:
            summary_lines.extend(recommendations)
        else:
            summary_lines.append("No specific recommendations provided.")
        
        summary_lines.append("")
        summary_lines.append("---")
        summary_lines.append(f"*Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
        summary_lines.append(f"*Source: {review_file.name}*")
        
        # Save summary
        summary_content = "\n".join(summary_lines)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(summary_content)
        
        console.print(f"[green]✓ Summary saved to: {output}[/green]")
        
        if verbose:
            console.print("\n[bold]Preview:[/bold]")
            console.print("---")
            console.print(summary_content[:500] + "...")
        
    except Exception as e:
        console.print(f"[red]Failed to generate summary: {e}[/red]")
        if verbose:
            import traceback
            console.print(traceback.format_exc())
        sys.exit(1)
```

---

## ANSWER KEY SUMMARY

### Multiple Choice Quick Reference

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | C | 14 | D |
| 2 | B | 15 | B |
| 3 | B | 16 | B |
| 4 | A | 17 | B |
| 5 | D | 18 | B |
| 6 | B | 19 | B |
| 7 | C | 20 | B |
| 8 | C | 21 | A |
| 9 | B | 22 | C |
| 10 | C | 23 | B |
| 11 | B | 24 | B |
| 12 | B | 25 | B |
| 13 | B | | |

### True/False Quick Reference

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 26 | False | 34 | False |
| 27 | True | 35 | True |
| 28 | False | 36 | False |
| 29 | True | 37 | True |
| 30 | False | 38 | True |
| 31 | False | 39 | False |
| 32 | True | 40 | True |
| 33 | False | | |

---

## TEST ADMINISTRATION GUIDE

### Suggested Test Formats

**1. Quick Knowledge Check (15 minutes)**
- 10 Multiple Choice Questions
- 5 True/False Questions
- For: After each Part

**2. Module Exam (30 minutes)**
- 15 Multiple Choice Questions
- 10 True/False Questions
- 2 Short Answer Questions
- For: End of each major section

**3. Comprehensive Exam (90 minutes)**
- 25 Multiple Choice Questions
- 15 True/False Questions
- 5 Short Answer Questions
- 2 Practical Questions
- For: Course completion

### Grading Rubric

**Multiple Choice & True/False**
- 1 point each
- No partial credit

**Short Answer**
- 5 points each
- Partial credit based on completeness
- Rubric: Understanding (3 pts) + Specificity (2 pts)

**Practical Questions**
- 15 points each
- Rubric: Code works (5 pts), Correct logic (5 pts), Documentation (5 pts)

### Passing Criteria

| Level | Requirement |
|-------|-------------|
| **Beginner** | 70% on Multiple Choice + True/False |
| **Intermediate** | 80% on all sections |
| **Advanced** | 85% on all sections + Complete Practical |

---

**END OF TEST BANK**

---

*This test bank provides comprehensive assessment materials for evaluating understanding of the Multi-Agent AI Architecture Review System. Use it for self-assessment, team training, or formal certification.*
