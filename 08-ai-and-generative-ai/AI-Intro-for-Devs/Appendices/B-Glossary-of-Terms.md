# AI Tutorial Series: Developer Edition
# Appendix B: Glossary of Terms

**A comprehensive reference of AI terminology, concepts, and acronyms used throughout the series.**

---

## Table of Contents

1. [A–C](#a-c)
2. [D–F](#d-f)
3. [G–I](#g-i)
4. [J–L](#j-l)
5. [M–O](#m-o)
6. [P–R](#p-r)
7. [S–U](#s-u)
8. [V–Z](#v-z)

---

## A–C

### Agent
An autonomous AI system that can plan, reason, use tools, and execute complex tasks to achieve goals. Unlike simple chatbots, agents can take initiative and perform actions.

**Example:** A research agent that gathers information, analyzes it, and writes a report.

### Agentic AI
AI systems that can act autonomously, make decisions, and execute complex workflows without constant human intervention.

### API (Application Programming Interface)
A set of rules and protocols for building and interacting with software applications. In AI, APIs allow developers to connect to AI models and services.

### API Key
A unique identifier used to authenticate API requests. API keys track usage and enforce rate limits.

### Attention Mechanism
A technique in transformer models that allows the model to focus on the most relevant parts of the input when generating output. It creates weighted relationships between all tokens in the context.

**Analogy:** Reading a document and paying more attention to key sentences than filler text.

### A/B Testing
A method of comparing two versions of a system (A and B) to determine which performs better. Used in AI to test different models, prompts, or configurations.

### Async / Asynchronous Programming
A programming paradigm that allows multiple operations to run concurrently without blocking each other. Essential for building responsive AI applications.

### Benchmarking
The process of measuring AI system performance against standardized tests or metrics to evaluate quality, speed, and cost.

### BPE (Byte-Pair Encoding)
A tokenization algorithm that iteratively merges the most frequent pairs of characters to create a vocabulary of tokens. Used by GPT models.

**Analogy:** Building common chunks from smaller pieces.

### Bulkhead Pattern
A resilience pattern that isolates different components of a system so that a failure in one component doesn't affect others. Like separate compartments in a ship.

### Caching
Storing responses to frequently asked questions or common queries to reduce latency and cost. Semantic caching stores responses based on meaning, not exact matches.

### Chain-of-Thought (CoT)
A prompting technique where the AI is asked to show its reasoning step by step, leading to more accurate and transparent responses.

**Example:** "Let's think through this step by step: 1. Start with 3 apples..."

### Chunking
The process of splitting large documents into smaller, manageable pieces for embedding and retrieval in RAG systems.

**Analogy:** Cutting a pizza into slices for easier handling.

### Circuit Breaker
A resilience pattern that stops requests to a failing service after a threshold of failures, allowing it time to recover. Prevents cascading failures.

**Analogy:** An electrical circuit breaker that trips when overloaded.

### CI/CD (Continuous Integration / Continuous Deployment)
A software development practice where code changes are automatically built, tested, and deployed to production. Essential for reliable AI system updates.

### Context Window
The maximum number of tokens an LLM can process in a single request. Includes both input and output tokens.

**Example:** GPT-4o-mini has a 128,000 token context window.

---

## D–F

### Deep Learning
A subset of machine learning that uses neural networks with multiple layers (deep neural networks) to learn hierarchical representations of data.

### Deployment
The process of making an AI application available for use in a production environment. Includes containerization, orchestration, and monitoring.

### Docker
A containerization platform that packages applications and their dependencies into standardized units called containers. Ensures consistency across environments.

### Embedding
A vector (list of numbers) that represents the meaning of a piece of text. Similar meanings have similar embeddings.

**Analogy:** A map where similar concepts are close together.

### Episodic Memory
A type of memory that stores specific events and experiences. In AI agents, episodic memory allows recall of past interactions.

**Analogy:** Remembering what you had for breakfast yesterday.

### Evaluation
The process of measuring AI system performance using metrics, benchmarks, user feedback, and automated testing.

### Exponential Backoff
A retry strategy where the delay between attempts increases exponentially (doubling each time). Often combined with jitter to prevent synchronized retries.

**Example:** Wait 1s, 2s, 4s, 8s between retries.

### FAISS (Facebook AI Similarity Search)
A library for efficient similarity search and clustering of dense vectors. Used for large-scale vector search in RAG systems.

### Fallback
A backup plan when a primary service fails. In AI, using a different model or returning a cached response when the primary model is unavailable.

### Feedback Loop
A process where outputs from an AI system are used to improve future outputs through user feedback, metrics, and automated optimization.

### Few-Shot Learning
A prompting technique where the AI is given a few examples of the desired input-output format before being asked to perform the task.

**Analogy:** Teaching someone with a few examples rather than extensive instruction.

### Function Calling
A feature that allows LLMs to call external functions and APIs, enabling them to interact with the real world. Also known as tool use.

---

## G–I

### Generative AI
AI systems that can create new content (text, images, audio, video) rather than just analyzing or classifying existing data.

### Goal Decomposition
The process of breaking down a complex goal into smaller, manageable sub-goals. Used by AI agents to plan complex tasks.

### GPU (Graphics Processing Unit)
A specialized processor originally designed for graphics that is also highly efficient for the parallel computations required by AI models.

### Graceful Degradation
The ability of a system to maintain partial functionality when some components fail, rather than completely crashing.

### Guardrails
Safety measures and constraints that prevent AI systems from producing harmful, inappropriate, or dangerous outputs.

### Hallucination
When an AI model generates information that is incorrect or fabricated but presented as factual. Often caused by pattern-matching without true understanding.

**Analogy:** A confident person who makes things up.

### Hybrid Search
Combining multiple search methods (e.g., keyword search and semantic search) for better retrieval results.

### Inference
The process of generating output from an AI model. For LLMs, this is the process of predicting the next token repeatedly to generate text.

### Jailbreak
An attempt to bypass an AI system's safety measures and constraints, causing it to behave in unintended or harmful ways.

### JSON (JavaScript Object Notation)
A lightweight data-interchange format that is easy for humans to read and write and easy for machines to parse and generate.

### Jitter
Random variation added to retry delays to prevent synchronized retries from multiple clients (the "thundering herd" problem).

---

## J–L

### Kubernetes (K8s)
An open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.

### Latency
The time it takes for a system to respond to a request. In AI, lower latency means faster responses and better user experience.

### LLM (Large Language Model)
A deep learning model trained on vast amounts of text data to understand and generate human-like language.

**Example:** GPT-4, Claude, Gemini, Llama.

### LLM-as-a-Judge
Using an LLM to evaluate the quality of outputs from other AI systems, providing automated, scalable evaluation.

### Load Balancer
A system that distributes incoming requests across multiple servers or models to ensure reliability and prevent overloading.

### Logging
Recording events, errors, and performance data from an AI system for debugging, monitoring, and analysis.

### Long-Term Memory
Persistent knowledge storage in AI agents that retains information across sessions. Often implemented using vector databases.

---

## M–O

### Machine Learning (ML)
A subset of AI where systems learn patterns from data rather than being explicitly programmed. The foundation of modern AI.

### Max Tokens
The maximum number of tokens an LLM can generate in a response. Limits output length and cost.

### MCP (Model Context Protocol)
An open protocol that standardizes how AI applications provide context to and interact with external systems, tools, and resources.

### Memory (Agent)
A component of AI agents that stores and retrieves information about past interactions, learned knowledge, and experiences.

### Memory Pruning
The process of removing old, irrelevant, or low-importance memories to keep memory systems efficient and within limits.

### Metadata
Data about data. In RAG systems, metadata includes source information, timestamps, topics, and categories for filtering and organization.

### Metrics
Quantitative measurements used to evaluate AI system performance. Examples: accuracy, latency, cost, success rate.

### Model Router
A system that intelligently selects which AI model to use for a given request based on cost, quality, capabilities, and other factors.

### Multi-Agent System
A system where multiple AI agents collaborate to solve complex problems. Agents can have different roles and communicate with each other.

**Analogy:** A team of specialists working together.

### Multimodal AI
AI systems that can process and generate across multiple data types (text, images, audio, video).

### Natural Language Processing (NLP)
The branch of AI focused on understanding and generating human language.

### Neural Network
A computing system inspired by biological neural networks that learns patterns from data through interconnected nodes (neurons).

### Next-Token Prediction
The fundamental mechanism of LLMs where the model predicts the next token in a sequence based on previous tokens.

**Analogy:** Predicting the next word in a sentence.

### Observability
The ability to understand what an AI system is doing through logs, traces, metrics, and monitoring. Essential for debugging and optimization.

### OCR (Optical Character Recognition)
Technology that extracts text from images, scanned documents, and PDFs.

### Orchestration
The coordination and management of multiple components, services, or agents to execute complex workflows.

---

## P–R

### Parallel Execution
Running multiple operations simultaneously to improve performance and reduce total execution time.

### Parent-Child Retrieval
A RAG technique where small chunks (children) are used for precise retrieval, but larger chunks (parents) are returned for context.

### Percentile
A statistical measure indicating the value below which a given percentage of observations fall. Used for latency measurement (e.g., P95 = 95th percentile).

### Planning (Agent)
The process by which an AI agent breaks down a goal into a sequence of actions or steps to achieve the desired outcome.

### Prompt
The input text given to an LLM to guide its generation. Includes instructions, context, and questions.

### Prompt Engineering
The art and science of crafting effective prompts to get desired outputs from LLMs. A crucial skill for AI developers.

### Prompt Injection
A security attack where malicious instructions are inserted into a prompt to override the system's intended behavior.

### Prompt Template
A reusable prompt structure with variables that can be filled in with specific values for different use cases.

### RAG (Retrieval-Augmented Generation)
A technique that combines retrieval of relevant documents with LLM generation to produce accurate, cited responses grounded in external knowledge.

**Analogy:** A student researching before writing an essay.

### Rate Limit
The maximum number of API requests allowed in a given time period. Exceeding rate limits results in errors (HTTP 429).

### Re-ranking
The process of reordering retrieved results to improve relevance, often using a more sophisticated model than the initial retrieval.

### Reflection (Agent)
The ability of an AI agent to evaluate its own performance, learn from mistakes, and improve future outputs. Self-improvement through critique.

**Analogy:** A craftsman reviewing their work to improve.

### Regression Testing
Testing to ensure that new changes or improvements don't break existing functionality. Essential for maintaining AI system stability.

### Resilience
The ability of a system to recover from failures and continue functioning. Includes retries, circuit breakers, and fallbacks.

### Resources (MCP)
Data and content that an MCP server can provide to clients. Includes files, database records, and API endpoints.

### Retry
Repeating a failed operation, often with a delay (backoff) to allow temporary issues to resolve.

---

## S–U

### Sampling
The process of selecting the next token during LLM generation based on the probability distribution. Controlled by temperature, Top-K, and Top-P.

### Schema
A structured definition of data format. In AI, JSON Schema defines the structure and types of expected outputs.

### Semantic Memory
A type of memory that stores general knowledge, concepts, and facts. In AI agents, semantic memory contains learned knowledge.

**Analogy:** Knowing that Paris is the capital of France.

### Semantic Search
Search based on meaning (using embeddings) rather than exact keyword matching. Finds documents that are semantically related to the query.

### SentencePiece
A tokenization algorithm that treats text as a stream of Unicode characters and builds tokens from them. Used by many modern LLMs including Llama and Gemini.

### Serverless
A cloud computing model where infrastructure management is abstracted away. Code runs in response to events and scales automatically.

### SSE (Server-Sent Events)
A technology for sending real-time updates from server to client over HTTP. Used for streaming AI responses to web applications.

### Short-Term Memory
Recent context and immediate state in an AI agent. Often corresponds to the current conversation or task context.

**Analogy:** What you remember from the last few minutes.

### Structured Output
Output from an LLM that follows a defined format (JSON, XML, etc.), making it easy to parse and integrate with other systems.

### System Prompt
Instructions given to an LLM at the start of a conversation that define its role, behavior, and constraints.

**Analogy:** A job description given before an interview.

### Temperature
A parameter that controls the randomness of LLM generation. Lower values (0.0) are deterministic; higher values (1.0+) are more creative/random.

**Analogy:** A creativity dial.

### Token
The smallest unit of text that an LLM processes. Can be a word, part of a word, punctuation, or a space.

**Analogy:** Letters in a word, but not exactly letters or words.

### Tokenization
The process of breaking text into tokens. Different models use different tokenization algorithms.

### Tool Call
A request from an LLM to execute a function or tool. Part of the function calling feature.

### Tool Use (Function Calling)
The ability of an LLM to call external functions and APIs to perform actions or retrieve information.

### Top-K
A sampling parameter that limits generation to the K most likely tokens, removing improbable options.

### Top-P (Nucleus Sampling)
A sampling parameter that considers only the smallest set of tokens whose cumulative probability exceeds P%. More dynamic than Top-K.

### Tracing
Tracking the flow of a request through a system, capturing timing and context for debugging and performance analysis.

### Transformer
The neural network architecture introduced in 2017 that powers modern LLMs. Uses attention mechanisms to process all tokens simultaneously.

### Truncation
Cutting off part of the context (usually older messages) to fit within the token limit. A simple memory management technique.

---

## V–Z

### Vector
A list of numbers that represents data in a mathematical space. In AI, embeddings are vectors that represent meaning.

### Vector Database
A database optimized for storing and searching vectors. Used in RAG systems for efficient similarity search.

**Examples:** Chroma, Pinecone, FAISS, Weaviate, Milvus, pgvector.

### Vision Model
An AI model that can process and understand images. Often multimodal models that can handle both images and text.

### WebSocket
A communication protocol that enables bidirectional, real-time communication between client and server. Used for chat applications and streaming.

### Workflow
A sequence of steps or operations to achieve a goal. In AI, workflows orchestrate multiple tools, agents, and services.

### Zero-Shot Learning
A prompting technique where the AI is asked to perform a task without any examples, relying only on its training.

**Analogy:** Asking someone to do something they've never done before.

---

## Common Acronyms

| Acronym | Full Name |
|---------|-----------|
| **AI** | Artificial Intelligence |
| **A2A** | Agent-to-Agent (communication) |
| **ANN** | Approximate Nearest Neighbor |
| **API** | Application Programming Interface |
| **BPE** | Byte-Pair Encoding |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **CoT** | Chain-of-Thought |
| **DL** | Deep Learning |
| **GPU** | Graphics Processing Unit |
| **JSON** | JavaScript Object Notation |
| **K8s** | Kubernetes |
| **LLM** | Large Language Model |
| **MCP** | Model Context Protocol |
| **ML** | Machine Learning |
| **NLP** | Natural Language Processing |
| **OCR** | Optical Character Recognition |
| **RAG** | Retrieval-Augmented Generation |
| **RPM** | Requests Per Minute |
| **SDK** | Software Development Kit |
| **SSE** | Server-Sent Events |
| **STM** | Short-Term Memory |
| **TPM** | Tokens Per Minute |
| **TTL** | Time To Live |

---

## Quick Reference: Roles in Multi-Agent Systems

| Role | Responsibility | Example Tasks |
|------|----------------|---------------|
| **Coordinator** | Plan, delegate, orchestrate | "Research this topic and write a report" |
| **Researcher** | Find and gather information | Search, read, extract data |
| **Analyzer** | Process and interpret data | Statistical analysis, pattern finding |
| **Writer** | Create content | Write reports, summaries, articles |
| **Reviewer** | Validate and improve | Quality check, fact-checking |
| **Task-Specific** | Specialized functions | Code generation, image creation |

---

## Quick Reference: Memory Types

| Type | Duration | Use |
|------|----------|-----|
| **Short-Term** | Minutes | Current conversation |
| **Long-Term** | Permanent | Persistent knowledge |
| **Episodic** | Permanent | Specific events |
| **Semantic** | Permanent | General facts |
| **Working** | Seconds | Immediate reasoning |

---

**End of Appendix B**

