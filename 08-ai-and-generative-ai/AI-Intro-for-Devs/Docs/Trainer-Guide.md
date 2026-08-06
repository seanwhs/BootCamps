# AI Tutorial Series: Developer Edition
# Trainer Guide

**A comprehensive guide for instructors teaching the AI Tutorial Series—with course planning, delivery strategies, facilitation techniques, and assessment guidance.**

---

## Table of Contents

1. [Course Overview](#course-overview)
2. [Trainer Preparation](#trainer-preparation)
3. [Teaching Philosophy](#teaching-philosophy)
4. [Module-by-Module Teaching Guide](#module-by-module-teaching-guide)
5. [Lecture Delivery Strategies](#lecture-delivery-strategies)
6. [Hands-On Lab Facilitation](#hands-on-lab-facilitation)
7. [Classroom Management](#classroom-management)
8. [Assessment & Evaluation](#assessment--evaluation)
9. [Troubleshooting Common Issues](#troubleshooting-common-issues)
10. [Additional Trainer Resources](#additional-trainer-resources)

---

## Course Overview

### Course Description

The **AI Tutorial Series: Developer Edition** is a comprehensive, code-first program designed to take software engineers from understanding how LLMs work to building and deploying production-grade AI applications. The course combines conceptual understanding with extensive hands-on coding across 7 phases, 24 modules, and 8 capstone projects.

### Course Structure

| Component | Details |
|-----------|---------|
| **Total Duration** | 24-28 hours of instruction (7 Phases × 3-4 hours) |
| **Format** | Instructor-led training (ILT) or self-paced |
| **Delivery** | Lectures + hands-on coding + capstone projects |
| **Prerequisites** | Basic Python, command line, REST APIs, JSON |
| **Target Audience** | Software engineers (1-5 years experience), technical product managers |

### Learning Objectives

By the end of this course, learners will be able to:

- Explain the mathematical and architectural foundations of Large Language Models
- Build robust AI applications using modern LLM APIs and SDKs
- Design reliable prompt engineering strategies and structured output pipelines
- Implement function calling and integrate external tools into AI workflows
- Build Retrieval-Augmented Generation (RAG) systems backed by vector databases
- Develop interoperable AI services using the Model Context Protocol (MCP)
- Engineer autonomous single-agent and multi-agent systems for complex task execution
- Apply asynchronous programming, resilience patterns, and observability to production AI workloads
- Secure AI applications against prompt injection, data leakage, and tool misuse
- Architect, deploy, evaluate, and continuously improve enterprise-grade AI solutions

---

## Trainer Preparation

### Technical Setup Checklist

Before the course begins:

- [ ] **Environment Verification**: Run the `verify_setup.py` script to confirm all participant environments are configured correctly
- [ ] **API Keys**: Ensure you have valid API keys for OpenAI, Anthropic, Google (and optionally OpenRouter)
- [ ] **Local Models**: Install and test Ollama with llama3.2 or similar models
- [ ] **Dependencies**: Confirm all required Python packages are installed (see course requirements)
- [ ] **Docker**: Verify Docker is installed and working on your trainer machine
- [ ] **Kubernetes**: If teaching deployment modules, ensure you have a Kubernetes cluster available (minikube, kind, or cloud-based)
- [ ] **Sample Data**: Prepare sample datasets for RAG modules
- [ ] **Presentation Setup**: Test slide decks, code demos, and screen sharing

### Trainer Knowledge Checklist

You should be comfortable with:

- [ ] Python programming (intermediate to advanced)
- [ ] API integration and REST principles
- [ ] Command line operations and environment variables
- [ ] Git version control
- [ ] Docker and containerization concepts
- [ ] Basic cloud concepts (AWS, GCP, or Azure)
- [ ] The core concepts covered in each module (see Module-by-Module guide below)

### Recommended Trainer Preparation Time

| Activity | Estimated Time |
|----------|----------------|
| Review all course materials | 20-30 hours |
| Run through all code demos | 10-15 hours |
| Complete all capstone projects | 15-20 hours |
| Prepare supplementary examples | 5-10 hours |
| **Total** | **50-75 hours** |

---

## Teaching Philosophy

### The "Learn by Building" Approach

This course is built on the principle that developers learn best by **building**, not just reading or listening. Every module includes hands-on coding exercises that reinforce the concepts.

**Trainer Principles:**

1. **Show, Don't Just Tell**: Always demonstrate concepts with live code
2. **Build Incrementally**: Each module builds on the previous one
3. **Encourage Experimentation**: Allow students to modify and break code
4. **Focus on Understanding**: Emphasize "why" over "what"
5. **Code-First**: Start with working code, then explain the concepts

### Classroom Environment

Create a classroom environment that encourages:

- **Questions**: Make it safe to ask questions at any time
- **Collaboration**: Encourage pair programming and discussion
- **Mistakes**: Celebrate mistakes as learning opportunities
- **Curiosity**: Allow tangents when students show interest

### Teaching Style Guidelines

| Do ✅ | Don't ❌ |
|-------|---------|
| Live-code examples | Read slides verbatim |
| Use analogies to explain concepts | Assume prior knowledge of AI |
| Pause for questions | Rush through complex topics |
| Connect concepts to real-world applications | Stay abstract and theoretical |
| Provide multiple examples | Provide only one perspective |
| Encourage experimentation | Stick strictly to the script |

---

## Module-by-Module Teaching Guide

### Phase 1: Understanding How LLMs Actually Work (4 hours)

#### Module 1: Introduction to Generative AI (45 min)

**Key Concepts to Emphasize:**
- AI vs. ML vs. DL vs. Generative AI
- The Transformer architecture and "Attention Is All You Need"
- Major model families and their use cases
- The difference between "thinking" and "pattern-matching"

**Teaching Tips:**
- Start with the "Library Analogy" to explain how LLMs work
- Show the evolution from rule-based systems to generative AI
- **Live Demo**: Make your first API call together
- Compare system prompts to show behavior differences

**Common Questions:**
- "Why are there so many different models?" → Explain trade-offs (cost, speed, quality)
- "Do I need to learn all of them?" → Focus on principles, not specific APIs

**Student Exercises:**
- Exercise 1.1: First API Call
- Exercise 1.2: Compare System Prompts

---

#### Module 2: Tokens & Embeddings (1 hour)

**Key Concepts to Emphasize:**
- Tokens vs. words
- Tokenization algorithms (BPE, SentencePiece)
- Embeddings as vectors of meaning
- Cosine similarity for semantic measurement

**Teaching Tips:**
- Use the "LEGO bricks" analogy for tokens
- Visualize embeddings as coordinates in semantic space
- **Live Demo**: Count tokens, generate embeddings, calculate similarity

**Common Questions:**
- "Why do I need to know about tokens?" → Tokens = cost, context limits
- "How do I choose an embedding model?" → Trade-off cost vs. quality

**Student Exercises:**
- Exercise 2.1: Token Counter
- Exercise 2.2: Embedding Generator

---

#### Module 3: How LLM Inference Works (1 hour)

**Key Concepts to Emphasize:**
- Next-token prediction
- Temperature, Top-K, Top-P
- Hallucinations and how to reduce them

**Teaching Tips:**
- Use the "What comes next?" game to explain prediction
- **Live Demo**: Generate text with different temperatures
- Show hallucinations and discuss how to prevent them

**Common Questions:**
- "What temperature should I use?" → It depends on the use case
- "Why do hallucinations happen?" → The model doesn't "know" facts

**Student Exercises:**
- Exercise 3.1: Temperature Experiment
- Exercise 3.2: Hallucination Detector

---

#### Module 4: Context Windows & Memory (1 hour)

**Key Concepts to Emphasize:**
- Context windows and their limits
- Memory management strategies
- Token usage and cost implications

**Teaching Tips:**
- Use the "Whiteboard" analogy for context windows
- **Live Demo**: Build a chatbot and show context overflow
- Compare different memory management strategies

**Common Questions:**
- "What happens when I exceed the context window?" → Error or truncation
- "Which memory strategy should I use?" → Depends on the use case

**Student Exercises:**
- Exercise 4.1: Simple Chatbot
- Exercise 4.2: Context-Aware Chatbot

---

### Phase 2: Prompt Engineering & Model APIs (4 hours)

#### Module 5: AI APIs (1 hour)

**Key Concepts to Emphasize:**
- Different providers and their authentication
- Rate limits and handling strategies
- Cost optimization

**Teaching Tips:**
- Use the "Restaurant" analogy for API providers
- Compare pricing and features across providers
- **Live Demo**: Build a multi-provider client

**Common Questions:**
- "Which provider should I use?" → Depends on your needs
- "How do I handle rate limits?" → Exponential backoff

**Student Exercises:**
- Exercise 5.1: Multi-Provider Client
- Exercise 5.2: Streaming Chat

---

#### Module 6: Prompt Engineering Fundamentals (1.5 hours)

**Key Concepts to Emphasize:**
- System prompts vs. user prompts
- Chain-of-Thought
- Few-shot learning
- Self-consistency

**Teaching Tips:**
- Use the "Interviewer" analogy
- **Live Demo**: Compare different system prompts
- Show Chain-of-Thought on a math problem

**Common Questions:**
- "How do I write a good system prompt?" → Be specific, give examples
- "When should I use few-shot learning?" → For structured output

**Student Exercises:**
- Exercise 6.1: System Prompt Comparison
- Exercise 6.2: Chain-of-Thought Implementation

---

#### Module 7: Structured Outputs (1.5 hours)

**Key Concepts to Emphasize:**
- JSON mode and schemas
- Data extraction (email, resume, invoice)
- Validation and error handling

**Teaching Tips:**
- Use the "Data Entry Clerk" analogy
- **Live Demo**: Build an email parser
- Emphasize validation for production systems

**Common Questions:**
- "Why use structured outputs?" → Automation, integration
- "How do I handle parsing errors?" → Try/except, recovery

**Student Exercises:**
- Exercise 7.1: Email Parser
- Exercise 7.2: Resume Parser

---

#### Module 8: Multimodal AI (1 hour)

**Key Concepts to Emphasize:**
- Vision understanding and OCR
- Speech-to-text and text-to-speech
- Image generation

**Teaching Tips:**
- Use the "Sensory" analogy
- **Live Demo**: Analyze an image, transcribe audio
- Show real-world applications

**Common Questions:**
- "Which model supports vision?" → GPT-4o, Claude 3.5, Gemini
- "How accurate is OCR?" → Very good with good image quality

**Student Exercises:**
- Exercise 8.1: Image Understanding
- Exercise 8.2: Speech-to-Text

---

### Phase 3: AI Tool Use & Function Calling (3-4 hours)

#### Module 9: Function Calling (1.5 hours)

**Key Concepts to Emphasize:**
- What function calling is
- Tool schemas and definitions
- Execution and handling results

**Teaching Tips:**
- Use the "Chef and Assistants" analogy
- **Live Demo**: Build weather, calculator, SQL tools
- Show the full function calling flow

**Common Questions:**
- "When does the model call a function?" → When it decides it needs to
- "How do I validate function arguments?" → Schema validation

**Student Exercises:**
- Exercise 9.1: Weather Tool
- Exercise 9.2: Multi-Tool Assistant

---

#### Module 10: Tool Orchestration (1 hour)

**Key Concepts to Emphasize:**
- Sequential vs. parallel execution
- Workflows and dependency management
- Error recovery

**Teaching Tips:**
- Use the "Orchestra Conductor" analogy
- **Live Demo**: Build a workflow with multiple steps
- Show error handling

**Common Questions:**
- "When would I use sequential vs. parallel?" → Depends on dependencies
- "How do I handle tool failures?" → Retry, fallback

**Student Exercises:**
- Exercise 10.1: Sequential Tool Execution
- Exercise 10.2: Workflow Builder

---

#### Module 11: Model Context Protocol (MCP) (1 hour)

**Key Concepts to Emphasize:**
- What MCP is and why it exists
- MCP architecture (Client, Server, Resources, Prompts, Tools)
- Transports and security

**Teaching Tips:**
- Use the "USB-C" analogy
- **Live Demo**: Build a simple MCP server and client
- Show discovery and capability listing

**Common Questions:**
- "How is MCP different from function calling?" → MCP is a standard
- "Do I need to use MCP?" → Not required, but recommended for interoperability

**Student Exercises:**
- Exercise 11.1: MCP Server
- Exercise 11.2: MCP Client

---

### Phase 4: Retrieval-Augmented Generation (RAG) (4-5 hours)

#### Module 12: Embeddings & Vector Databases (1.5 hours)

**Key Concepts to Emphasize:**
- Document chunking
- Embedding generation
- Vector databases and search
- Similarity search

**Teaching Tips:**
- Use the "Library" analogy
- **Live Demo**: Chunk documents, generate embeddings, build a vector store
- Search for semantic matches

**Common Questions:**
- "What chunk size should I use?" → 300-500 tokens is typical
- "Which vector database should I use?" → Chroma for dev, Pinecone for prod

**Student Exercises:**
- Exercise 12.1: Document Chunker
- Exercise 12.2: Vector Store

---

#### Module 13: Building a RAG Pipeline (2 hours)

**Key Concepts to Emphasize:**
- End-to-end RAG pipeline
- Document ingestion
- Retrieval and context construction
- Generation with citations

**Teaching Tips:**
- Use the "Research Assistant" analogy
- **Live Demo**: Build a complete RAG pipeline
- Show citations in responses

**Common Questions:**
- "How does RAG reduce hallucinations?" → Grounds responses in facts
- "What's the difference between RAG and fine-tuning?" → RAG uses external knowledge

**Student Exercises:**
- Exercise 13.1: Simple RAG Pipeline
- Exercise 13.2: Citation-Enabled RAG

---

#### Module 14: Advanced RAG (1.5 hours)

**Key Concepts to Emphasize:**
- Hybrid search
- Context compression
- Parent-child retrieval
- Knowledge graph integration

**Teaching Tips:**
- Use the "Detective" analogy
- **Live Demo**: Implement hybrid search
- Show parent-child retrieval in action

**Common Questions:**
- "When should I use hybrid search?" → When you need both exact and semantic matches
- "What's parent-child retrieval?" → Precision + context

**Student Exercises:**
- Exercise 14.1: Hybrid Search
- Exercise 14.2: Advanced RAG Pipeline

---

### Phase 5: Agentic AI Systems (4-5 hours)

#### Module 15: AI Agents (2 hours)

**Key Concepts to Emphasize:**
- What makes an AI agent
- Planning and reasoning
- Reflection and learning
- Goal decomposition

**Teaching Tips:**
- Use the "Employee" analogy
- **Live Demo**: Build a simple agent with planning
- Show reflection improving performance

**Common Questions:**
- "How is an agent different from a chatbot?" → Agents take action
- "Do agents always need tools?" → Not always, but they benefit from them

**Student Exercises:**
- Exercise 15.1: Simple Agent
- Exercise 15.2: Self-Improving Agent

---

#### Module 16: Multi-Agent Systems (1.5 hours)

**Key Concepts to Emphasize:**
- Coordinator and worker agents
- Communication patterns
- Hierarchical and swarm architectures

**Teaching Tips:**
- Use the "Team" analogy
- **Live Demo**: Build coordinator and worker agents
- Show communication between agents

**Common Questions:**
- "When should I use multiple agents?" → Complex tasks with specialized roles
- "How do agents communicate?" → Direct messaging, broadcast, pub/sub

**Student Exercises:**
- Exercise 16.1: Multi-Agent Team
- Exercise 16.2: Autonomous Research Team

---

#### Module 17: Agent Memory (1.5 hours)

**Key Concepts to Emphasize:**
- Short-term, long-term, episodic, semantic memory
- Memory consolidation and pruning
- Retrieval strategies

**Teaching Tips:**
- Use the "Human Memory" analogy
- **Live Demo**: Build a memory system
- Show consolidation in action

**Common Questions:**
- "Why do agents need memory?" → To learn and improve
- "When should I prune memories?" → When memory is full or irrelevant

**Student Exercises:**
- Exercise 17.1: Memory System
- Exercise 17.2: Learning Agent

---

### Phase 6: AI Application Engineering (5-6 hours)

#### Module 18: Asynchronous AI Programming (1.5 hours)

**Key Concepts to Emphasize:**
- Async vs. sync performance
- Streaming responses
- SSE and WebSockets

**Teaching Tips:**
- Use the "Restaurant" analogy
- **Live Demo**: Build an async AI client
- Show streaming responses

**Common Questions:**
- "Is async always faster?" → For I/O-bound operations
- "When should I use streaming?" → For better UX

**Student Exercises:**
- Exercise 18.1: Async AI Client
- Exercise 18.2: Real-Time Chat Server

---

#### Module 19: Resilient AI Systems (1.5 hours)

**Key Concepts to Emphasize:**
- Retry with exponential backoff
- Circuit breakers
- Timeouts and rate limiting
- Bulkhead pattern

**Teaching Tips:**
- Use the "Building" analogy
- **Live Demo**: Implement retry and circuit breaker
- Show failure handling

**Common Questions:**
- "When should I retry?" → For transient failures
- "When should I use a circuit breaker?" → For cascading failures

**Student Exercises:**
- Exercise 19.1: Retry with Exponential Backoff
- Exercise 19.2: Resilient API Client

---

#### Module 20: AI Observability (1.5 hours)

**Key Concepts to Emphasize:**
- Structured logging
- Tracing
- Token and cost monitoring
- Latency analysis
- Prompt versioning

**Teaching Tips:**
- Use the "Dashboard" analogy
- **Live Demo**: Build a structured logger
- Show cost monitoring

**Common Questions:**
- "Why is observability important?" → To debug and optimize
- "What should I monitor?" → Tokens, cost, latency, errors

**Student Exercises:**
- Exercise 20.1: Structured Logger
- Exercise 20.2: Complete Observability Stack

---

#### Module 21: AI Security (1 hour)

**Key Concepts to Emphasize:**
- Prompt injection and jailbreak prevention
- Data leakage protection
- Secret management
- Tool abuse prevention
- Guardrails

**Teaching Tips:**
- Use the "Bank Vault" analogy
- **Live Demo**: Build a prompt injection detector
- Show redaction of sensitive data

**Common Questions:**
- "What's the most common AI attack?" → Prompt injection
- "How do I prevent data leakage?" → Output filtering

**Student Exercises:**
- Exercise 21.1: Prompt Injection Detector
- Exercise 21.2: Security Guardrails

---

### Phase 7: Production AI Architecture (4-5 hours)

#### Module 22: AI System Architecture (1.5 hours)

**Key Concepts to Emphasize:**
- AI gateways
- Model routing
- Response caching
- Load balancing
- Model fallback

**Teaching Tips:**
- Use the "Airport" analogy
- **Live Demo**: Build a model router
- Show cost-based routing

**Common Questions:**
- "How do I decide which model to use?" → Cost, quality, latency trade-offs
- "What's the benefit of caching?" → Reduced cost and latency

**Student Exercises:**
- Exercise 22.1: Model Router
- Exercise 22.2: AI Gateway

---

#### Module 23: Deployment (1.5 hours)

**Key Concepts to Emphasize:**
- Docker containerization
- Kubernetes orchestration
- Serverless AI
- CI/CD pipelines

**Teaching Tips:**
- Use the "Delivery Service" analogy
- **Live Demo**: Dockerize an AI service
- Show Kubernetes deployment

**Common Questions:**
- "When should I use serverless vs. Kubernetes?" → Sporadic vs. consistent workloads
- "Do I need CI/CD?" → Yes, for reliable deployments

**Student Exercises:**
- Exercise 23.1: Dockerize an AI Service
- Exercise 23.2: Complete Deployment Pipeline

---

#### Module 24: AI Evaluation & Continuous Improvement (1.5 hours)

**Key Concepts to Emphasize:**
- Benchmarking
- A/B testing
- LLM-as-a-Judge
- Feedback loops
- Regression testing

**Teaching Tips:**
- Use the "Quality Control" analogy
- **Live Demo**: Build an A/B testing system
- Show LLM-as-a-Judge evaluation

**Common Questions:**
- "How do I know if my model is improving?" → Metrics and evaluation
- "What's LLM-as-a-Judge?" → Using AI to evaluate AI

**Student Exercises:**
- Exercise 24.1: LLM-as-a-Judge
- Exercise 24.2: Complete Evaluation Pipeline

---

## Lecture Delivery Strategies

### Effective Lecture Structure

1. **Hook (5 min)**: Start with a real-world example or question
2. **Concept Introduction (10 min)**: Use analogy and simple explanation
3. **Deep Dive (15 min)**: Detailed explanation with visuals
4. **Live Demo (15 min)**: Show the concept in code
5. **Hands-On Exercise (30-45 min)**: Students apply the concept
6. **Q&A and Wrap-Up (10 min)**: Address questions, recap

### Visual Presentation Tips

- **Use Analogies**: Start every major concept with an analogy
- **Show, Don't Tell**: Always have a live demo ready
- **Keep Slides Clean**: Minimal text, maximum visuals
- **Annotate Code**: Explain what each line does
- **Use Diagrams**: Visualize architecture and workflows

### Live Coding Best Practices

- **Prepare Code Snippets**: Have code ready, but type it live when possible
- **Explain as You Type**: Narrate your thought process
- **Encourage Following Along**: Students should code with you
- **Pause for Questions**: Check understanding frequently
- **Use Error Handling**: Show common errors and how to fix them

### Balancing Theory and Practice

| Phase | Theory % | Practice % |
|-------|----------|------------|
| Phase 1 | 60% | 40% |
| Phase 2 | 40% | 60% |
| Phase 3 | 30% | 70% |
| Phase 4 | 30% | 70% |
| Phase 5 | 25% | 75% |
| Phase 6 | 20% | 80% |
| Phase 7 | 30% | 70% |

---

## Hands-On Lab Facilitation

### Lab Structure

1. **Setup (5 min)**: Review the exercise and environment
2. **Independent Work (20-30 min)**: Students code individually or in pairs
3. **Group Discussion (10 min)**: Share approaches and challenges
4. **Instructor Solution Walkthrough (10 min)**: Show the solution
5. **Q&A (5 min)**: Address remaining questions

### Common Lab Issues and Solutions

| Issue | Solution |
|-------|----------|
| API key errors | Guide students through setting environment variables |
| Rate limiting | Implement exponential backoff or use local models |
| Import errors | Review the correct import paths |
| Memory issues | Reduce chunk sizes or batch sizes |
| Model not found | Verify model names and availability |

### Lab Facilitation Tips

- **Walk the Room**: Monitor student progress and offer help
- **Identify Struggling Students**: Offer one-on-one assistance
- **Encourage Peer Help**: Students can learn from each other
- **Use a Timer**: Keep students on track
- **Celebrate Successes**: Acknowledge completed exercises

---

## Classroom Management

### Handling Questions

- **Welcome Questions**: Create a safe space for questions
- **Address Questions Immediately**: Don't wait until the end
- **Use the "Parking Lot"**: For off-topic questions
- **Answer Questions with Questions**: Encourage critical thinking
- **Admit When You Don't Know**: Show how to find answers

### Managing Different Skill Levels

- **Advanced Students**: Provide extension challenges
- **Struggling Students**: Offer additional support
- **Group Work**: Pair advanced students with struggling ones
- **Self-Paced Options**: Allow students to skip ahead or review

### Creating an Inclusive Environment

- **Use Diverse Examples**: Avoid tech-bro culture
- **Avoid Jargon**: Explain technical terms clearly
- **Respect Different Backgrounds**: Everyone comes from different experiences
- **Use Inclusive Language**: Use "they" as a singular pronoun

---

## Assessment & Evaluation

### Formative Assessment (During Course)

| Method | Frequency | Purpose |
|--------|-----------|---------|
| **Module Quizzes** | After each module | Check understanding |
| **Lab Completion** | During each module | Verify practical skills |
| **Class Participation** | Throughout | Engagement |
| **Peer Feedback** | During labs | Collaboration |

### Summative Assessment (End of Course)

| Method | Purpose |
|--------|---------|
| **Phase Tests** | Cumulative understanding |
| **Capstone Projects** | Applied skills |
| **Final Exam** | Comprehensive mastery |

### Grading Guidelines

| Component | Weight |
|-----------|--------|
| Module Quizzes | 15% |
| Lab Exercises | 25% |
| Phase Tests | 20% |
| Capstone Projects | 25% |
| Final Exam | 15% |

### Sample Grading Rubric (Capstone Project)

| Criteria | Excellent (5) | Good (4) | Satisfactory (3) | Needs Improvement (2) | Unsatisfactory (1) |
|----------|---------------|----------|------------------|---------------------|-------------------|
| **Functionality** | Fully functional | Mostly functional | Some features work | Minimal features work | Non-functional |
| **Code Quality** | Clean, well-documented | Good structure | Acceptable | Messy | Unreadable |
| **Documentation** | Comprehensive | Good | Basic | Minimal | None |
| **Innovation** | Novel approach | Some creativity | Standard | Minimal | None |

---

## Troubleshooting Common Issues

### Environment Issues

| Issue | Solution |
|-------|----------|
| **Python version mismatch** | Ensure Python 3.10+ is installed |
| **Dependency conflicts** | Use a fresh virtual environment |
| **API key not found** | Check .env file and load_dotenv() |
| **Package not installed** | Run `pip install -r requirements.txt` |
| **Port already in use** | Kill the process or use a different port |

### API Issues

| Issue | Solution |
|-------|----------|
| **Rate limiting (429)** | Implement exponential backoff |
| **Authentication error (401)** | Check API key format and validity |
| **Bad request (400)** | Check parameter types and required fields |
| **Model not found** | Verify model name spelling |
| **Timeout** | Increase timeout or retry |

### Model Issues

| Issue | Solution |
|-------|----------|
| **Hallucinations** | Use RAG, lower temperature |
| **Slow responses** | Use a faster model or smaller max_tokens |
| **Repetitive output** | Adjust temperature, add frequency penalty |
| **Off-topic responses** | Improve system prompt |
| **Unstructured output** | Use JSON mode or structured prompts |

### RAG Issues

| Issue | Solution |
|-------|----------|
| **Poor retrieval** | Tune Top-K, use hybrid search, improve chunking |
| **Context overflow** | Use context compression, reduce chunk size |
| **Missing citations** | Improve the generation prompt |
| **Slow retrieval** | Use a faster vector database, reduce chunk count |
| **Irrelevant documents** | Use metadata filtering, improve embeddings |

---

## Additional Trainer Resources

### Sample Course Schedule (5 Days)

| Day | Morning (3 hours) | Afternoon (2-3 hours) |
|-----|-------------------|----------------------|
| **Day 1** | Introduction, Module 1 | Modules 2-3 |
| **Day 2** | Module 4, Phase 1 Capstone | Modules 5-6 |
| **Day 3** | Modules 7-8, Phase 2 Capstone | Modules 9-10 |
| **Day 4** | Modules 11-12, Phase 3 Capstone | Modules 13-14 |
| **Day 5** | Modules 15-16, Phase 4 Capstone | Modules 17-18 |
| **Day 6** | Modules 19-20, Phase 5 Capstone | Modules 21-22 |
| **Day 7** | Modules 23-24, Phase 6 Capstone | Phase 7 Capstone, Wrap-up |

### Sample Course Schedule (10 Weeks, 2x per week)

| Week | Session 1 (2 hours) | Session 2 (2 hours) |
|------|---------------------|---------------------|
| **Week 1** | Introduction, Module 1 | Modules 2-3 |
| **Week 2** | Module 4, Phase 1 Capstone | Modules 5-6 |
| **Week 3** | Modules 7-8 | Phase 2 Capstone |
| **Week 4** | Modules 9-10 | Module 11 |
| **Week 5** | Phase 3 Capstone | Modules 12-13 |
| **Week 6** | Module 14, Phase 4 Capstone | Modules 15-16 |
| **Week 7** | Module 17, Phase 5 Capstone | Modules 18-19 |
| **Week 8** | Modules 20-21 | Phase 6 Capstone |
| **Week 9** | Modules 22-23 | Module 24, Phase 7 Capstone |
| **Week 10** | Capstone Presentations | Final Exam, Wrap-up |

### Trainer Cheat Sheet: Key Analogies

| Concept | Analogy |
|---------|---------|
| LLMs | Pattern-matching machines |
| Context Window | A whiteboard |
| Tokens | LEGO bricks |
| Embeddings | Coordinates in semantic space |
| Temperature | A creativity dial |
| Function Calling | A chef with assistants |
| RAG | A research assistant in a library |
| Agents | Employees with goals |
| Multi-Agent Systems | A team of specialists |
| Asynchronous | Multiple chefs working simultaneously |
| Circuit Breaker | A fire door |
| Observability | A cockpit dashboard |
| Prompt Injection | Tricking a security guard |
| AI Gateway | The main airport terminal |

---

## Trainer Self-Care

### Teaching Can Be Exhausting

- **Stay Healthy**: Get enough sleep and exercise
- **Take Breaks**: Rest between sessions
- **Don't Overprepare**: Trust your knowledge
- **Embrace Imperfection**: It's okay if things go wrong
- **Learn from Each Session**: Reflect and improve

### Continuous Improvement

- **Record Yourself**: Watch your lectures to improve
- **Ask for Feedback**: From students and peers
- **Stay Current**: AI evolves rapidly
- **Network with Other Trainers**: Share best practices
- **Update Materials**: Keep them fresh and relevant

---

**End of Trainer Guide**

---

## Quick Reference: Module Durations

| Module | Estimated Duration |
|--------|-------------------|
| Module 1 | 45 min |
| Module 2 | 1 hour |
| Module 3 | 1 hour |
| Module 4 | 1 hour |
| Module 5 | 1 hour |
| Module 6 | 1.5 hours |
| Module 7 | 1.5 hours |
| Module 8 | 1 hour |
| Module 9 | 1.5 hours |
| Module 10 | 1 hour |
| Module 11 | 1 hour |
| Module 12 | 1.5 hours |
| Module 13 | 2 hours |
| Module 14 | 1.5 hours |
| Module 15 | 2 hours |
| Module 16 | 1.5 hours |
| Module 17 | 1.5 hours |
| Module 18 | 1.5 hours |
| Module 19 | 1.5 hours |
| Module 20 | 1.5 hours |
| Module 21 | 1 hour |
| Module 22 | 1.5 hours |
| Module 23 | 1.5 hours |
| Module 24 | 1.5 hours |
| **Total** | **~30 hours** |
