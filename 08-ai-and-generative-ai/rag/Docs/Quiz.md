# Quiz and Test Bank: Bridging the Gap — Enterprise RAG, Vector Databases, and Agentic Orchestration

## Overview

This document provides a complete assessment bank for the "Bridging the Gap" series. It includes:

- **Pre-course Assessment**: Gauge student readiness
- **Part Quizzes**: Check understanding after each part
- **Mid-Course Test**: Comprehensive assessment after Part 2
- **Final Exam**: Complete assessment for the entire series
- **Practical Assessments**: Hands-on coding tests
- **Answer Keys**: Complete solutions with explanations
- **Grading Rubrics**: Clear evaluation criteria

---

## Pre-Course Assessment

### Purpose
Gauge students' existing knowledge before starting the course.

### Duration
30 minutes

### Format
25 multiple-choice questions

---

### Questions

**Q1:** What is an API key used for in AI applications?
- A) To encrypt all data
- B) To authenticate requests to a service
- C) To store database connections
- D) To generate embeddings

**Q2:** Which command installs the TypeScript compiler?
- A) `npm install typescript`
- B) `npm install tsc`
- C) `npm install @types/node`
- D) `npm install ts-node`

**Q3:** What does `async/await` do in JavaScript?
- A) Makes code run faster
- B) Handles asynchronous operations
- C) Creates new threads
- D) Compiles TypeScript

**Q4:** What is Docker used for?
- A) Writing JavaScript code
- B) Containerizing applications
- C) Managing databases
- D) Running AI models

**Q5:** What is an environment variable?
- A) A variable set at runtime
- B) A TypeScript type
- C) A database schema
- D) A function parameter

**Q6:** What is the `node_modules` directory?
- A) Project source code
- B) Installed dependencies
- C) Build output
- D) Database files

**Q7:** What is a vector?
- A) A database table
- B) An array of numbers
- C) A string of text
- D) A JSON object

**Q8:** What is TypeScript?
- A) A superset of JavaScript with types
- B) A new programming language
- C) A database system
- D) A testing framework

**Q9:** What is npm?
- A) Node Package Manager
- B) New Programming Model
- C) Network Performance Monitor
- D) Native Package Manager

**Q10:** What is the purpose of a `.gitignore` file?
- A) To ignore Git commands
- B) To exclude files from version control
- C) To configure Git branches
- D) To store Git secrets

**Q11:** What is an LLM?
- A) Large Language Model
- B) Low Latency Memory
- C) Linear Logic Module
- D) Layered Learning Method

**Q12:** What is a REST API?
- A) A style of web service
- B) A database connection
- C) A programming language
- D) A testing tool

**Q13:** What is JSON?
- A) JavaScript Object Notation
- B) Java Serialized Object Notation
- C) JSON Object Model
- D) JavaScript Output Node

**Q14:** What is PostgreSQL?
- A) A NoSQL database
- B) A relational database
- C) A web server
- D) A programming language

**Q15:** What is Redis?
- A) A SQL database
- B) An in-memory data store
- C) A vector database
- D) A web framework

**Q16:** What is the difference between `git pull` and `git clone`?
- A) `pull` updates, `clone` copies
- B) `pull` copies, `clone` updates
- C) Both are the same
- D) Neither is a Git command

**Q17:** What is a dependency in software?
- A) External code your project uses
- B) A built-in Node module
- C) A configuration file
- D) A test file

**Q18:** What is a prompt in AI?
- A) The input given to an LLM
- B) The output of an LLM
- C) The training data
- D) The model weights

**Q19:** What is a token in the context of LLMs?
- A) A piece of text (word/subword)
- B) A security credential
- C) A database entry
- D) A file format

**Q20:** What is an embedding?
- A) A numerical representation of text
- B) A type of database
- C) A JavaScript framework
- D) A data format

**Q21:** What is a vector database?
- A) A database optimized for vector search
- B) A traditional SQL database
- C) A document database
- D) A graph database

**Q22:** What is context in RAG?
- A) Retrieved information used by the LLM
- B) The model's training data
- C) The system configuration
- D) The API endpoint

**Q23:** What is a hallucination in AI?
- A) A false or made-up response
- B) A creative response
- C) A correct response
- D) An error message

**Q24:** What is the difference between `require` and `import`?
- A) `require` is CommonJS, `import` is ESM
- B) `import` is CommonJS, `require` is ESM
- C) Both are the same
- D) Neither is valid JavaScript

**Q25:** What is a TypeScript interface?
- A) A way to define object shapes
- B) A function definition
- C) A class implementation
- D) A file extension

---

### Answer Key — Pre-Course Assessment

| Q# | Answer | Explanation |
|----|--------|-------------|
| 1 | B | API keys authenticate requests to services like OpenAI |
| 2 | A | `npm install typescript` installs the TypeScript compiler |
| 3 | B | `async/await` handles asynchronous operations in JavaScript |
| 4 | B | Docker is used for containerizing applications |
| 5 | A | Environment variables are set at runtime |
| 6 | B | `node_modules` contains installed dependencies |
| 7 | B | A vector is an array of numbers |
| 8 | A | TypeScript is a superset of JavaScript with types |
| 9 | A | npm stands for Node Package Manager |
| 10 | B | `.gitignore` excludes files from version control |
| 11 | A | LLM stands for Large Language Model |
| 12 | A | REST API is a style of web service |
| 13 | A | JSON is JavaScript Object Notation |
| 14 | B | PostgreSQL is a relational database |
| 15 | B | Redis is an in-memory data store |
| 16 | A | `git pull` updates, `git clone` copies |
| 17 | A | A dependency is external code your project uses |
| 18 | A | A prompt is the input given to an LLM |
| 19 | A | A token is a piece of text (word/subword) |
| 20 | A | An embedding is a numerical representation of text |
| 21 | A | A vector database is optimized for vector search |
| 22 | A | Context is retrieved information used by the LLM |
| 23 | A | A hallucination is a false or made-up response |
| 24 | A | `require` is CommonJS, `import` is ESM |
| 25 | A | A TypeScript interface defines object shapes |

---

## Part 1 Quiz: RAG Foundation

### Purpose
Assess understanding of basic RAG concepts and implementation.

### Duration
30 minutes

### Format
15 multiple-choice + 5 short answer

---

### Multiple Choice Questions

**Q1:** What are the three main stages of a RAG pipeline?
- A) Load, Process, Store
- B) Ingestion, Retrieval, Generation
- C) Input, Process, Output
- D) Embed, Search, Respond

**Q2:** What is the purpose of chunking in RAG?
- A) To make documents smaller for storage
- B) To break documents into manageable pieces
- C) To encrypt document content
- D) To format documents for display

**Q3:** Which chunking strategy uses a hierarchy of separators?
- A) Fixed-size chunking
- B) Recursive chunking
- C) Semantic chunking
- D) Marker-based chunking

**Q4:** What dimension does `text-embedding-3-small` produce?
- A) 384
- B) 768
- C) 1536
- D) 3072

**Q5:** Which algorithm does pgvector use for approximate nearest neighbor search?
- A) HNSW
- B) K-means
- C) Decision Tree
- D) Linear Regression

**Q6:** What is cosine similarity?
- A) A measure of angle between vectors
- B) A measure of distance between vectors
- C) A database index type
- D) A machine learning algorithm

**Q7:** What is the recommended chunk size for general RAG?
- A) 100-200 tokens
- B) 500-1000 tokens
- C) 2000-5000 tokens
- D) 10000+ tokens

**Q8:** What is a similarity threshold used for?
- A) Filtering low-relevance results
- B) Increasing search speed
- C) Sorting results
- D) Embedding generation

**Q9:** Which Node.js framework is used in the series for the main application?
- A) Express.js
- B) Fastify
- C) NestJS
- D) Koa

**Q10:** What type of database is pgvector?
- A) NoSQL
- B) Relational with vector extension
- C) Graph database
- D) Document database

**Q11:** What is the purpose of metadata in RAG?
- A) To provide context about document sources
- B) To store vector data
- C) To generate embeddings
- D) To format responses

**Q12:** What is the output of an embedding model?
- A) A vector
- B) A string
- C) A number
- D) A boolean

**Q13:** What is the recommended overlap between chunks?
- A) 0%
- B) 5-10%
- C) 10-20%
- D) 50%

**Q14:** What is the `topK` parameter used for?
- A) Number of results to return
- B) Number of tokens to generate
- C) Number of embeddings to create
- D) Number of documents to ingest

**Q15:** What is the purpose of the generator in RAG?
- A) To produce answers from retrieved context
- B) To create embeddings
- C) To store documents
- D) To load documents

---

### Short Answer Questions

**Q16:** Explain why chunking is important in RAG. Include at least three reasons.

**Q17:** Describe the process of generating and storing embeddings. What are the key steps?

**Q18:** How does similarity search work in a vector database? Explain the key components.

**Q19:** What are the key differences between fixed-size chunking and recursive chunking?

**Q20:** Why is metadata important in RAG systems? Give at least two examples.

---

### Answer Key — Part 1 Quiz

#### Multiple Choice

| Q# | Answer | Explanation |
|----|--------|-------------|
| 1 | B | The three stages are Ingestion, Retrieval, Generation |
| 2 | B | Chunking breaks documents into manageable pieces |
| 3 | B | Recursive chunking uses a hierarchy of separators |
| 4 | C | text-embedding-3-small produces 1536 dimensions |
| 5 | A | pgvector uses HNSW (Hierarchical Navigable Small World) |
| 6 | A | Cosine similarity measures angle between vectors |
| 7 | B | 500-1000 tokens is the recommended range |
| 8 | A | A similarity threshold filters low-relevance results |
| 9 | B | The series uses Fastify for the API server |
| 10 | B | pgvector is PostgreSQL with vector extension |
| 11 | A | Metadata provides context about document sources |
| 12 | A | An embedding model outputs a vector |
| 13 | C | 10-20% overlap is recommended |
| 14 | A | topK controls the number of results returned |
| 15 | A | The generator produces answers from retrieved context |

#### Short Answer — Sample Answers

**Q16:** Chunking is important because:
1. LLMs have context window limits
2. Smaller chunks are more focused and relevant
3. Allows for more efficient retrieval
4. Prevents dilution of relevant information
5. Enables better matching of query to content

**Q17:** Key steps in embedding generation and storage:
1. Load the document
2. Chunk the document into pieces
3. Send each chunk to the embedding API
4. Receive vector representation
5. Store vector with metadata in vector database
6. Create indexes for fast retrieval

**Q18:** Similarity search works by:
1. Embedding the query text
2. Comparing query vector to stored vectors
3. Calculating similarity scores (e.g., cosine)
4. Returning documents with highest scores
5. Key components: vector index, distance metric, similarity threshold

**Q19:** Key differences:
- Fixed-size: Chunks of equal size, simple, may break meaning
- Recursive: Uses separators hierarchically, preserves meaning, more computationally intensive

**Q20:** Metadata is important because:
1. Provides source attribution (which document the chunk came from)
2. Enables filtering and governance (access control)
3. Helps with debugging and tracing
4. Example: source filename, timestamp, document type, access level

---

## Part 2 Quiz: Advanced Retrieval

### Purpose
Assess understanding of hybrid search, reranking, and governance.

### Duration
30 minutes

### Format
15 multiple-choice + 5 short answer

---

### Multiple Choice Questions

**Q1:** What is the purpose of BM25 in RAG?
- A) To perform semantic search
- B) To perform lexical search
- C) To generate embeddings
- D) To rerank results

**Q2:** What does BM25 stand for?
- A) Best Matching 25
- B) Basic Model 25
- C) Binary Metric 25
- D) Bayesian Method 25

**Q3:** What is RRF?
- A) Reciprocal Rank Fusion
- B) Recursive Ranking Function
- C) Rapid Retrieval Framework
- D) Relevance Ranking Formula

**Q4:** What is the standard value of k in RRF?
- A) 10
- B) 30
- C) 60
- D) 100

**Q5:** What is the main difference between a bi-encoder and a cross-encoder?
- A) Cross-encoder processes query and document together
- B) Bi-encoder processes query and document together
- C) Cross-encoder is faster
- D) Bi-encoder is more accurate

**Q6:** Which model is used for cross-encoder reranking in the series?
- A) `text-embedding-3-small`
- B) `cross-encoder/ms-marco-MiniLM-L-6-v2`
- C) `all-MiniLM-L6-v2`
- D) `gpt-4o-mini`

**Q7:** What is metadata governance used for?
- A) Access control and filtering
- B) Generating embeddings
- C) Creating chunks
- D) Loading documents

**Q8:** What is the benefit of hybrid search?
- A) Combines semantic and lexical search strengths
- B) Faster than either method alone
- C) Uses less memory
- D) Requires no embeddings

**Q9:** What is a search attempt in the agent context?
- A) A single retrieval operation
- B) A document loading operation
- C) An embedding generation
- D) A generation operation

**Q10:** What is the purpose of reranking?
- A) To improve result precision
- B) To speed up search
- C) To reduce memory usage
- D) To increase chunk size

**Q11:** What type of search does BM25 perform?
- A) Keyword/lexical search
- B) Semantic search
- C) Hybrid search
- D) Neural search

**Q12:** What is the role of the BM25 index manager?
- A) To keep the index current
- B) To generate embeddings
- C) To store documents
- D) To create chunks

**Q13:** What is the relationship between k1 and b in BM25?
- A) k1 controls term saturation, b controls length normalization
- B) k1 controls length, b controls saturation
- C) Both control the same thing
- D) Neither is used in BM25

**Q14:** What is the recommended refresh interval for BM25 indexes?
- A) 1 minute
- B) 5 minutes
- C) 1 hour
- D) 1 day

**Q15:** What is the purpose of the governance layer?
- A) To apply access filters to results
- B) To generate new documents
- C) To create embeddings
- D) To load files

---

### Short Answer Questions

**Q16:** Explain why hybrid search is more effective than either semantic or lexical search alone.

**Q17:** Describe how Reciprocal Rank Fusion works and why it's used.

**Q18:** What is the difference between bi-encoders and cross-encoders? When should each be used?

**Q19:** Explain the concept of metadata governance and provide three examples of governance rules.

**Q20:** Describe the complete hybrid retrieval pipeline and the role of each component.

---

### Answer Key — Part 2 Quiz

#### Multiple Choice

| Q# | Answer | Explanation |
|----|--------|-------------|
| 1 | B | BM25 performs lexical/keyword search |
| 2 | A | BM25 stands for Best Matching 25 |
| 3 | A | RRF is Reciprocal Rank Fusion |
| 4 | C | The standard k value in RRF is 60 |
| 5 | A | Cross-encoders process query and document together |
| 6 | B | This is the cross-encoder model used in the series |
| 7 | A | Metadata governance controls access through filtering |
| 8 | A | Hybrid search combines strengths of both methods |
| 9 | A | A search attempt is a single retrieval operation |
| 10 | A | Reranking improves precision of results |
| 11 | A | BM25 performs keyword/lexical search |
| 12 | A | The index manager keeps the BM25 index current |
| 13 | A | k1 controls term saturation, b controls length normalization |
| 14 | B | 5 minutes is the recommended refresh interval |
| 15 | A | The governance layer applies access filters to results |

#### Short Answer — Sample Answers

**Q16:** Hybrid search is more effective because:
1. Semantic search captures meaning but misses exact terms
2. Lexical search captures exact terms but misses meaning
3. Combining them handles more query types
4. Different queries benefit from different approaches
5. RRF optimally combines both ranking signals

**Q17:** RRF works by:
1. Taking rankings from multiple search methods
2. Calculating scores as 1/(k + rank) for each method
3. Summing scores for each document
4. Ranking by total score
5. Benefits: no score normalization needed, handles different score scales

**Q18:** Bi-encoders vs Cross-encoders:
- Bi-encoder: Embeds query and documents separately, faster, used for initial retrieval
- Cross-encoder: Processes query + document together, more accurate, slower, used for reranking

**Q19:** Metadata governance:
1. Controls access based on user permissions
2. Example rules: Public users only see public documents
3. Team members only see team documents
4. Admins see all documents

**Q20:** Hybrid retrieval pipeline:
1. Dense search: Embed query, search vector database
2. Lexical search: Tokenize query, BM25 search
3. RRF fusion: Combine results from both methods
4. Reranking: Cross-encoder refines results
5. Governance: Apply access filters
6. Return final results

---

## Part 3 Quiz: Orchestration

### Purpose
Assess understanding of LangChain.js orchestration.

### Duration
30 minutes

### Format
15 multiple-choice + 5 short answer

---

### Multiple Choice Questions

**Q1:** What is a Runnable in LangChain.js?
- A) A standard interface for operations
- B) A database connection
- C) A file loader
- D) A logging service

**Q2:** Which method composes Runnables together?
- A) `.pipe()`
- B) `.connect()`
- C) `.link()`
- D) `.chain()`

**Q3:** What is the purpose of structured output?
- A) To ensure LLM responses follow a format
- B) To make responses faster
- C) To reduce token usage
- D) To load documents

**Q4:** Which library is used for schema validation in the series?
- A) Zod
- B) Joi
- C) Yup
- D) PropTypes

**Q5:** What is a prompt template?
- A) A reusable prompt with variables
- B) A fixed prompt string
- C) A system configuration
- D) A response format

**Q6:** What is the purpose of telemetry in RAG?
- A) To monitor system behavior
- B) To generate embeddings
- C) To load documents
- D) To create chunks

**Q7:** What is a trace in telemetry?
- A) A record of a request's path
- B) A system metric
- C) A configuration file
- D) A database record

**Q8:** What is the purpose of the orchestrator?
- A) To tie all components together
- B) To load documents
- C) To generate embeddings
- D) To create chunks

**Q9:** What does `RunnableSequence.from()` do?
- A) Creates a sequential pipeline
- B) Creates a parallel pipeline
- C) Creates a database connection
- D) Creates a logging service

**Q10:** What is the benefit of provider abstraction?
- A) Easy to switch between LLM providers
- B) Faster performance
- C) Less code required
- D) More accurate results

**Q11:** What is the purpose of the OutputFixingParser?
- A) To automatically fix malformed outputs
- B) To generate outputs faster
- C) To create embeddings
- D) To load documents

**Q12:** What is a span in distributed tracing?
- A) A single operation within a trace
- B) A complete request
- C) A system metric
- D) A configuration setting

**Q13:** What is the purpose of creating a fallback runnable?
- A) To handle failures gracefully
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

**Q14:** What is LangSmith used for?
- A) Monitoring LLM applications
- B) Generating embeddings
- C) Storing documents
- D) Creating chunks

**Q15:** What is the purpose of the `invoke()` method on Runnables?
- A) To execute the runnable with input
- B) To connect to a database
- C) To load a file
- D) To generate embeddings

---

### Short Answer Questions

**Q16:** Explain the concept of a Runnable in LangChain.js and how it enables composability.

**Q17:** Describe the benefits of structured output and how to implement it with Zod.

**Q18:** What are the key components of a telemetry system and why are they important?

**Q19:** Explain the relationship between traces, spans, and events in distributed tracing.

**Q20:** How does the orchestrator tie together different components of the RAG system?

---

### Answer Key — Part 3 Quiz

#### Multiple Choice

| Q# | Answer | Explanation |
|----|--------|-------------|
| 1 | A | Runnable is a standard interface for operations |
| 2 | A | `.pipe()` composes Runnables together |
| 3 | A | Structured output ensures responses follow a format |
| 4 | A | Zod is used for schema validation |
| 5 | A | A prompt template is a reusable prompt with variables |
| 6 | A | Telemetry monitors system behavior |
| 7 | A | A trace records a request's path |
| 8 | A | The orchestrator ties all components together |
| 9 | A | Creates a sequential pipeline |
| 10 | A | Provider abstraction makes switching providers easy |
| 11 | A | Fixes malformed outputs |
| 12 | A | A span is a single operation within a trace |
| 13 | A | Handles failures gracefully |
| 14 | A | LangSmith monitors LLM applications |
| 15 | A | `invoke()` executes the runnable with input |

#### Short Answer — Sample Answers

**Q16:** Runnables are the building blocks of LangChain.js:
1. Standard interface: `invoke()`, `stream()`, `batch()`
2. Composable via `.pipe()`: outputs become inputs
3. Enables reuse and testing
4. Provides error handling and retries
5. Supports streaming and batching

**Q17:** Benefits of structured output:
1. Type safety: Zod validates response shape
2. Consistency: Same format every time
3. Integration: Easier to use with other systems
4. Implementation: Define Zod schema, use OutputParser

**Q18:** Telemetry components:
1. Traces: Track entire requests
2. Spans: Individual operations within traces
3. Events: Specific occurrences
4. Metrics: Quantitative measurements
5. All important for debugging, monitoring, and optimization

**Q19:** Relationship:
1. Trace: Complete request journey
2. Spans: Individual operations within the trace
3. Events: Details within spans
4. Hierarchy: Trace > Spans > Events

**Q20:** Orchestrator ties together:
1. Runnables: Composed pipeline
2. Prompts: Template management
3. Validation: Structured output
4. Telemetry: Tracing and metrics
5. Configuration: All components

---

## Part 4 Quiz: Agents

### Purpose
Assess understanding of LangGraph.js agents.

### Duration
30 minutes

### Format
15 multiple-choice + 5 short answer

---

### Multiple Choice Questions

**Q1:** What is the difference between a pipeline and an agent?
- A) Agents are cyclic, pipelines are linear
- B) Pipelines are faster
- C) Agents use less memory
- D) Pipelines have more features

**Q2:** What does LangGraph.js provide?
- A) Stateful agent workflows
- B) Static pipelines
- C) Database connections
- D) File loading

**Q3:** What is a node in LangGraph.js?
- A) An operation that modifies state
- B) A database table
- C) A configuration file
- D) A log entry

**Q4:** What is an edge in LangGraph.js?
- A) A transition between nodes
- B) A data structure
- C) A database connection
- D) A configuration setting

**Q5:** What is the purpose of conditional edges?
- A) To branch based on state
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

**Q6:** What is a state annotation?
- A) A type definition for state
- B) A database table
- C) A configuration file
- D) A log entry

**Q7:** What is the purpose of checkpoints?
- A) To save and restore state
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

**Q8:** What is the search node responsible for?
- A) Retrieving documents
- B) Generating answers
- C) Evaluating quality
- D) Reflecting on results

**Q9:** What is the evaluate node responsible for?
- A) Assessing result quality
- B) Retrieving documents
- C) Generating answers
- D) Reflecting on results

**Q10:** What is the generate node responsible for?
- A) Creating draft answers
- B) Retrieving documents
- C) Assessing quality
- D) Reflecting on results

**Q11:** What is the reflect node responsible for?
- A) Reviewing and improving answers
- B) Retrieving documents
- C) Assessing quality
- D) Creating drafts

**Q12:** What is HITL?
- A) Human-in-the-loop
- B) High-level testing language
- C) Hardware interface technology language
- D) Hierarchical iterative tool learning

**Q13:** What is the purpose of parallel execution?
- A) To run multiple operations simultaneously
- B) To speed up database queries
- C) To reduce memory usage
- D) To generate embeddings

**Q14:** What is the `AbortController` used for?
- A) Canceling operations
- B) Starting operations
- C) Managing memory
- D) Loading files

**Q15:** What is the purpose of the `maxIterations` parameter?
- A) To prevent infinite loops
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

---

### Short Answer Questions

**Q16:** Explain the difference between a pipeline and an agent. When would you use each?

**Q17:** Describe the flow of a LangGraph.js agent. What are the main nodes and how do they interact?

**Q18:** What is human-in-the-loop and why is it important in agent systems?

**Q19:** Explain the concept of checkpointing and why it's useful.

**Q20:** How does self-correction work in the agent system?

---

### Answer Key — Part 4 Quiz

#### Multiple Choice

| Q# | Answer | Explanation |
|----|--------|-------------|
| 1 | A | Agents are cyclic, pipelines are linear |
| 2 | A | LangGraph.js provides stateful agent workflows |
| 3 | A | A node is an operation that modifies state |
| 4 | A | An edge is a transition between nodes |
| 5 | A | Conditional edges branch based on state |
| 6 | A | State annotations define state types |
| 7 | A | Checkpoints save and restore state |
| 8 | A | Search node retrieves documents |
| 9 | A | Evaluate node assesses result quality |
| 10 | A | Generate node creates draft answers |
| 11 | A | Reflect node reviews and improves answers |
| 12 | A | HITL stands for Human-in-the-loop |
| 13 | A | Parallel execution runs operations simultaneously |
| 14 | A | AbortController cancels operations |
| 15 | A | maxIterations prevents infinite loops |

#### Short Answer — Sample Answers

**Q16:** Pipeline vs Agent:
- Pipeline: Linear, predictable, faster, good for simple tasks
- Agent: Cyclic, adaptable, self-correcting, good for complex tasks

**Q17:** Agent flow:
1. Search: Retrieve documents
2. Evaluate: Assess relevance and extract evidence
3. Generate: Create draft answer
4. Reflect: Review and improve
5. Repeat if needed
6. Complete when satisfactory

**Q18:** Human-in-the-loop:
1. System pauses for human input
2. Used for approval, clarification, or feedback
3. Important for safety, accuracy, and building trust
4. Implemented with approval nodes and notifications

**Q19:** Checkpointing:
1. Saves current state at key points
2. Allows resuming from failures
3. Enables human review and debugging
4. Important for long-running workflows

**Q20:** Self-correction:
1. Assesses answer quality
2. If poor, identifies issues
3. Improves query or approach
4. Retries with better strategy
5. Repeats until quality threshold met

---

## Mid-Course Test (Parts 1-2)

### Purpose
Comprehensive assessment after completing Parts 1 and 2.

### Duration
60 minutes

### Format
30 multiple-choice + 10 short answer

---

### Multiple Choice Questions (30)

**Q1:** What does RAG stand for?
- A) Retrieval-Augmented Generation
- B) Recursive Algorithm Generator
- C) Random Access Gateway
- D) Resource Allocation Graph

**Q2:** Which stage of RAG involves converting text to vectors?
- A) Embedding
- B) Chunking
- C) Loading
- D) Generation

**Q3:** What is the recommended chunk size for general RAG?
- A) 100 tokens
- B) 500-1000 tokens
- C) 5000 tokens
- D) 10000 tokens

**Q4:** Which pgvector index is used for fast similarity search?
- A) HNSW
- B) B-tree
- C) Hash
- D) GiST

**Q5:** What is the output dimension of `text-embedding-3-small`?
- A) 384
- B) 768
- C) 1536
- D) 3072

**Q6:** What is cosine similarity used for?
- A) Comparing vector similarity
- B) Generating text
- C) Loading documents
- D) Creating chunks

**Q7:** Which search method uses keyword matching?
- A) Lexical search
- B) Semantic search
- C) Neural search
- D) Hybrid search

**Q8:** What is BM25?
- A) A lexical ranking algorithm
- B) A semantic search method
- C) A vector database
- D) A language model

**Q9:** What does RRF stand for?
- A) Reciprocal Rank Fusion
- B) Recursive Ranking Function
- C) Rapid Retrieval Framework
- D) Relevance Ranking Formula

**Q10:** What is the purpose of reranking?
- A) To improve result precision
- B) To speed up search
- C) To reduce memory usage
- D) To increase chunk size

**Q11:** What is a cross-encoder?
- A) A model that processes query and document together
- B) A vector database
- C) A chunking strategy
- D) A file loader

**Q12:** What is the standard k value in RRF?
- A) 10
- B) 30
- C) 60
- D) 100

**Q13:** What is the difference between dense and lexical search?
- A) Dense uses meaning, lexical uses keywords
- B) Dense is faster
- C) Lexical is more accurate
- D) They are the same

**Q14:** What is metadata governance?
- A) Access control and filtering
- B) Vector generation
- C) Document loading
- D) Text chunking

**Q15:** What is the purpose of a similarity threshold?
- A) To filter low-relevance results
- B) To speed up search
- C) To sort results
- D) To generate embeddings

**Q16:** What is the benefit of hybrid search?
- A) Combines strengths of dense and lexical search
- B) Is faster than both
- C) Uses less memory
- D) Requires no embeddings

**Q17:** What is a BM25 index manager responsible for?
- A) Keeping the index current
- B) Generating embeddings
- C) Storing documents
- D) Creating chunks

**Q18:** What is the purpose of the governance layer?
- A) Applying access filters to results
- B) Generating new documents
- C) Creating embeddings
- D) Loading files

**Q19:** What is a search attempt?
- A) A single retrieval operation
- B) A document loading operation
- C) An embedding generation
- D) A generation operation

**Q20:** What is the recommended BM25 refresh interval?
- A) 1 minute
- B) 5 minutes
- C) 1 hour
- D) 1 day

**Q21:** What is the `topK` parameter used for?
- A) Number of results to return
- B) Number of tokens to generate
- C) Number of embeddings to create
- D) Number of documents to ingest

**Q22:** Which chunking strategy uses a hierarchy of separators?
- A) Recursive chunking
- B) Fixed-size chunking
- C) Semantic chunking
- D) Marker-based chunking

**Q23:** What is the purpose of metadata in RAG?
- A) Providing context about document sources
- B) Storing vector data
- C) Generating embeddings
- D) Formatting responses

**Q24:** What is the output of an embedding model?
- A) A vector
- B) A string
- C) A number
- D) A boolean

**Q25:** What is the recommended overlap between chunks?
- A) 0%
- B) 5-10%
- C) 10-20%
- D) 50%

**Q26:** What is the purpose of the generator in RAG?
- A) Producing answers from retrieved context
- B) Creating embeddings
- C) Storing documents
- D) Loading documents

**Q27:** What is the difference between bi-encoder and cross-encoder?
- A) Cross-encoder processes query and document together
- B) Bi-encoder is more accurate
- C) Cross-encoder is faster
- D) They are the same

**Q28:** What is the purpose of RRF fusion?
- A) Combining rankings from multiple search methods
- B) Speeding up search
- C) Reducing memory usage
- D) Generating embeddings

**Q29:** What is the relationship between k1 and b in BM25?
- A) k1 controls term saturation, b controls length normalization
- B) k1 controls length, b controls saturation
- C) Both control the same thing
- D) Neither is used in BM25

**Q30:** What is the purpose of the chunking overlap?
- A) To maintain context between chunks
- B) To reduce chunk size
- C) To speed up processing
- D) To eliminate duplicates

---

### Short Answer Questions (10)

**Q31:** Explain the complete RAG pipeline from document ingestion to answer generation.

**Q32:** Describe the difference between lexical search (BM25) and semantic search (dense vectors). When would you use each?

**Q33:** Explain how RRF works and why it's beneficial for hybrid search.

**Q34:** What is cross-encoder reranking and why is it used?

**Q35:** Explain the concept of metadata governance and provide three examples.

**Q36:** Describe the advantages and trade-offs of using hybrid search with reranking.

**Q37:** What factors should you consider when choosing a chunking strategy?

**Q38:** Explain how pgvector enables vector similarity search in PostgreSQL.

**Q39:** What is the difference between a similarity threshold and `topK`?

**Q40:** Describe the end-to-end process of retrieving and generating an answer in a RAG system.

---

### Answer Key — Mid-Course Test

#### Multiple Choice

| Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|
| 1 | A | 11 | A | 21 | A |
| 2 | A | 12 | C | 22 | A |
| 3 | B | 13 | A | 23 | A |
| 4 | A | 14 | A | 24 | A |
| 5 | C | 15 | A | 25 | C |
| 6 | A | 16 | A | 26 | A |
| 7 | A | 17 | A | 27 | A |
| 8 | A | 18 | A | 28 | A |
| 9 | A | 19 | A | 29 | A |
| 10 | A | 20 | B | 30 | A |

#### Short Answer — Sample Answers

**Q31:** Complete RAG pipeline:
1. Ingestion: Load documents, chunk into pieces, embed each chunk, store in vector database
2. Retrieval: Embed query, search vector database, get relevant chunks
3. Generation: Build prompt with query and context, send to LLM, return answer

**Q32:** Difference between searches:
- Lexical search (BM25): Matches exact terms, uses term frequency, good for keywords
- Semantic search: Matches meaning, uses embeddings, good for concepts
- Use lexical for exact matches, semantic for meaning-based queries

**Q33:** RRF works by:
1. Taking rankings from multiple methods
2. Calculating scores as 1/(k + rank)
3. Summing scores for each document
4. Ranking by total score
5. Benefits: No score normalization needed, handles different scales

**Q34:** Cross-encoder reranking:
1. Processes query + document together
2. Generates more accurate relevance scores
3. Used to refine initial retrieval results
4. Trade-off: More accurate but slower

**Q35:** Metadata governance:
1. Controls access based on user permissions
2. Example rules: public vs internal documents, department access, clearance levels
3. Implemented with metadata filters

**Q36:** Hybrid search advantages/trade-offs:
- Advantages: Better recall, handles more query types
- Trade-offs: More complex, potentially slower
- Reranking adds accuracy but increases latency

**Q37:** Chunking strategy factors:
- Document structure (format, sections)
- Query types (keyword vs semantic)
- Context window limits
- Performance requirements

**Q38:** pgvector enables search by:
1. Adding vector data type
2. Providing similarity operators (<->, <#>)
3. Supporting HNSW indexes for fast search
4. Allowing metadata filtering

**Q39:** Difference:
- Similarity threshold: Minimum relevance score to include result
- topK: Maximum number of results to return

**Q40:** End-to-end process:
1. Query arrives
2. Query is embedded
3. Vector search finds similar chunks
4. (Optional) Hybrid search with lexical
5. (Optional) Reranking
6. Results filtered by governance
7. Context assembled from results
8. Prompt built with context and query
9. LLM generates response
10. Response returned with sources

---

## Final Exam

### Purpose
Comprehensive assessment for the entire series.

### Duration
120 minutes

### Format
40 multiple-choice + 10 short answer + 1 coding problem

---

### Multiple Choice Questions (40)

**Q1:** What are the three main stages of a RAG pipeline?
- A) Load, Process, Store
- B) Ingestion, Retrieval, Generation
- C) Input, Process, Output
- D) Embed, Search, Respond

**Q2:** What is the purpose of chunking in RAG?
- A) To break documents into manageable pieces
- B) To encrypt document content
- C) To format documents for display
- D) To compress documents

**Q3:** What dimension does `text-embedding-3-small` produce?
- A) 384
- B) 768
- C) 1536
- D) 3072

**Q4:** What is a Runnable in LangChain.js?
- A) A standard interface for operations
- B) A database connection
- C) A file loader
- D) A logging service

**Q5:** What is the purpose of BM25 in RAG?
- A) To perform lexical search
- B) To perform semantic search
- C) To generate embeddings
- D) To rerank results

**Q6:** What does RRF stand for?
- A) Reciprocal Rank Fusion
- B) Recursive Ranking Function
- C) Rapid Retrieval Framework
- D) Relevance Ranking Formula

**Q7:** What is a node in LangGraph.js?
- A) An operation that modifies state
- B) A database table
- C) A configuration file
- D) A log entry

**Q8:** What is HITL?
- A) Human-in-the-loop
- B) High-level testing language
- C) Hardware interface technology language
- D) Hierarchical iterative tool learning

**Q9:** What is the purpose of structured output?
- A) To ensure LLM responses follow a format
- B) To make responses faster
- C) To reduce token usage
- D) To load documents

**Q10:** What is the purpose of telemetry in RAG?
- A) To monitor system behavior
- B) To generate embeddings
- C) To load documents
- D) To create chunks

**Q11:** What is the standard k value in RRF?
- A) 10
- B) 30
- C) 60
- D) 100

**Q12:** What is a cross-encoder?
- A) A model that processes query and document together
- B) A vector database
- C) A chunking strategy
- D) A file loader

**Q13:** What is the purpose of checkpoints in LangGraph.js?
- A) To save and restore state
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

**Q14:** Which chunking strategy uses a hierarchy of separators?
- A) Recursive chunking
- B) Fixed-size chunking
- C) Semantic chunking
- D) Marker-based chunking

**Q15:** What is the benefit of hybrid search?
- A) Combines strengths of dense and lexical search
- B) Is faster than both
- C) Uses less memory
- D) Requires no embeddings

**Q16:** What is the purpose of metadata governance?
- A) Access control and filtering
- B) Vector generation
- C) Document loading
- D) Text chunking

**Q17:** What is the recommended overlap between chunks?
- A) 0%
- B) 5-10%
- C) 10-20%
- D) 50%

**Q18:** What is the difference between a pipeline and an agent?
- A) Agents are cyclic, pipelines are linear
- B) Pipelines are faster
- C) Agents use less memory
- D) Pipelines have more features

**Q19:** What is the purpose of the evaluate node?
- A) Assessing result quality
- B) Retrieving documents
- C) Generating answers
- D) Reflecting on results

**Q20:** What is a trace in telemetry?
- A) A record of a request's path
- B) A system metric
- C) A configuration file
- D) A database record

**Q21:** What is the recommended chunk size for general RAG?
- A) 100-200 tokens
- B) 500-1000 tokens
- C) 2000-5000 tokens
- D) 10000+ tokens

**Q22:** What is the purpose of `topK`?
- A) Number of results to return
- B) Number of tokens to generate
- C) Number of embeddings to create
- D) Number of documents to ingest

**Q23:** What is the purpose of the generate node?
- A) Creating draft answers
- B) Retrieving documents
- C) Assessing quality
- D) Reflecting on results

**Q24:** What is the purpose of the reflect node?
- A) Reviewing and improving answers
- B) Retrieving documents
- C) Assessing quality
- D) Creating drafts

**Q25:** What is the purpose of the orchestrator?
- A) To tie all components together
- B) To load documents
- C) To generate embeddings
- D) To create chunks

**Q26:** What is the benefit of provider abstraction?
- A) Easy to switch between LLM providers
- B) Faster performance
- C) Less code required
- D) More accurate results

**Q27:** What is the purpose of the BM25 index manager?
- A) To keep the index current
- B) To generate embeddings
- C) To store documents
- D) To create chunks

**Q28:** What is the recommended BM25 refresh interval?
- A) 1 minute
- B) 5 minutes
- C) 1 hour
- D) 1 day

**Q29:** What is the purpose of the `AbortController`?
- A) Canceling operations
- B) Starting operations
- C) Managing memory
- D) Loading files

**Q30:** What is the purpose of the `maxIterations` parameter?
- A) To prevent infinite loops
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

**Q31:** What is the purpose of RRF fusion?
- A) Combining rankings from multiple search methods
- B) Speeding up search
- C) Reducing memory usage
- D) Generating embeddings

**Q32:** What is the difference between bi-encoder and cross-encoder?
- A) Cross-encoder processes query and document together
- B) Bi-encoder is more accurate
- C) Cross-encoder is faster
- D) They are the same

**Q33:** What is the purpose of the governance layer?
- A) Applying access filters to results
- B) Generating new documents
- C) Creating embeddings
- D) Loading files

**Q34:** What is the purpose of the chunking overlap?
- A) To maintain context between chunks
- B) To reduce chunk size
- C) To speed up processing
- D) To eliminate duplicates

**Q35:** What is the relationship between k1 and b in BM25?
- A) k1 controls term saturation, b controls length normalization
- B) k1 controls length, b controls saturation
- C) Both control the same thing
- D) Neither is used in BM25

**Q36:** What is the purpose of parallel execution?
- A) To run multiple operations simultaneously
- B) To speed up database queries
- C) To reduce memory usage
- D) To generate embeddings

**Q37:** What is a span in distributed tracing?
- A) A single operation within a trace
- B) A complete request
- C) A system metric
- D) A configuration setting

**Q38:** What is the purpose of the OutputFixingParser?
- A) To automatically fix malformed outputs
- B) To generate outputs faster
- C) To create embeddings
- D) To load documents

**Q39:** What is the purpose of conditional edges in LangGraph.js?
- A) To branch based on state
- B) To speed up execution
- C) To reduce memory usage
- D) To generate embeddings

**Q40:** What is the purpose of the search node?
- A) Retrieving documents
- B) Generating answers
- C) Evaluating quality
- D) Reflecting on results

---

### Short Answer Questions (10)

**Q41:** Explain the complete architecture of a RAG agent system, including all major components and how they interact.

**Q42:** Describe the process of document ingestion in detail, from loading to storage.

**Q43:** Explain how hybrid search works and why it improves retrieval quality.

**Q44:** Compare and contrast pipelines and agents. When would you use each?

**Q45:** Describe the role of LangChain.js in the system and how it enables orchestration.

**Q46:** Explain how the LangGraph.js agent works, including all nodes and their interactions.

**Q47:** What is human-in-the-loop and how is it implemented in the agent system?

**Q48:** Describe the telemetry system and why it's important for production systems.

**Q49:** Explain the checkpointing mechanism and its benefits.

**Q50:** What are the key considerations for deploying a RAG agent system to production?

---

### Coding Problem

**Q51:** Implement a function that performs hybrid search with reranking and governance.

**Requirements:**
1. Accept a query string and user context
2. Perform both dense and lexical search
3. Fuse results using RRF
4. Rerank using a cross-encoder
5. Apply governance filters
6. Return top-k results

**Grading Criteria:**
- Correct implementation of all steps (40%)
- Proper error handling (20%)
- Type safety (20%)
- Code quality and comments (20%)

---

### Answer Key — Final Exam

#### Multiple Choice

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 1 | B | 11 | C | 21 | B | 31 | A |
| 2 | A | 12 | A | 22 | A | 32 | A |
| 3 | C | 13 | A | 23 | A | 33 | A |
| 4 | A | 14 | A | 24 | A | 34 | A |
| 5 | A | 15 | A | 25 | A | 35 | A |
| 6 | A | 16 | A | 26 | A | 36 | A |
| 7 | A | 17 | C | 27 | A | 37 | A |
| 8 | A | 18 | A | 28 | B | 38 | A |
| 9 | A | 19 | A | 29 | A | 39 | A |
| 10 | A | 20 | A | 30 | A | 40 | A |

#### Short Answer — Sample Answers

**Q41:** Complete architecture:
1. Ingestion pipeline: Loader, chunker, embedder, vector DB
2. Retrieval pipeline: Dense search, lexical search, RRF fusion, reranking, governance
3. Orchestration: LangChain.js runnables, prompt templates, structured output
4. Agent: LangGraph.js state machine, nodes (search, evaluate, generate, reflect, HITL)
5. API: Fastify server with REST and WebSocket
6. Async: BullMQ queues for background processing
7. Persistence: Checkpoint storage, database
8. Telemetry: Tracing, metrics, logging

**Q42:** Document ingestion:
1. Load: Read from file system (PDF, text, markdown)
2. Chunk: Split into pieces using recursive chunking
3. Embed: Generate vectors using OpenAI embeddings
4. Store: Save chunks with embeddings in pgvector database
5. Index: Create HNSW indexes for fast search

**Q43:** Hybrid search:
1. Performs both dense (semantic) and lexical (keyword) search
2. Fuses results using RRF (Reciprocal Rank Fusion)
3. Uses ranks instead of scores for combination
4. Improves recall: Finds documents from both methods
5. Handles different query types better

**Q44:** Pipeline vs Agent:
- Pipeline: Linear, predictable, faster, good for simple tasks
- Agent: Cyclic, adaptable, self-correcting, good for complex tasks
- Use pipelines for straightforward queries
- Use agents for multi-step reasoning

**Q45:** LangChain.js role:
1. Provides Runnable interface for composable operations
2. Enables provider-agnostic LLM access
3. Offers prompt templates for consistent prompting
4. Supports structured output with Zod
5. Includes telemetry for monitoring

**Q46:** LangGraph.js agent:
1. Search: Retrieves documents based on query
2. Evaluate: Assesses result quality and extracts evidence
3. Generate: Creates draft answer from evidence
4. Reflect: Reviews quality and improves if needed
5. HITL: Pauses for human approval if needed
6. Cycles through nodes until complete

**Q47:** Human-in-the-loop:
1. Agent pauses at decision points
2. Sends approval request with context
3. Waits for human response (with timeout)
4. Continues based on human input
5. Important for safety, quality, trust

**Q48:** Telemetry system:
1. Traces: Track request flow through system
2. Spans: Individual operations within traces
3. Events: Significant occurrences
4. Metrics: Quantitative measurements
5. Important for debugging, monitoring, optimization

**Q49:** Checkpointing:
1. Saves state at key points
2. Enables resuming from failures
3. Allows human review
4. Important for long-running workflows
5. Implemented with file-based or database storage

**Q50:** Production considerations:
1. Environment configuration
2. Database connection pooling
3. Queue management
4. Error handling and retries
5. Monitoring and alerts
6. Security (authentication, encryption)
7. Scaling strategy
8. Backup and disaster recovery

#### Coding Problem — Sample Solution

```typescript
async function hybridSearchWithReranking(
  query: string,
  userContext: UserContext,
  options: {
    topK?: number;
    denseWeight?: number;
    lexicalWeight?: number;
    useReranking?: boolean;
  } = {}
): Promise<SearchResult[]> {
  const {
    topK = 5,
    denseWeight = 0.5,
    lexicalWeight = 0.5,
    useReranking = true,
  } = options;

  try {
    // 1. Perform dense search
    const queryEmbedding = await embedder.embedText(query);
    const denseResults = await vectorDB.similaritySearch(
      queryEmbedding,
      topK * 2, // Get more for fusion
      0.7 // threshold
    );

    // 2. Perform lexical search
    const lexicalResults = await lexicalSearch.search(query, topK * 2);

    // 3. Fuse results using RRF
    const fusedResults = fusion.fuseWeighted(
      [denseResults, lexicalResults],
      ['dense', 'lexical'],
      [denseWeight, lexicalWeight],
      topK * 2
    );

    // 4. Rerank if enabled
    let finalResults = fusedResults;
    if (useReranking) {
      finalResults = await reranker.rerank(query, fusedResults, topK);
    } else {
      finalResults = fusedResults.slice(0, topK);
    }

    // 5. Apply governance
    const governedResults = governance.applyGovernance(
      finalResults,
      userContext
    );

    // 6. Return results with metadata
    return governedResults.map(result => ({
      ...result,
      metadata: {
        ...result.metadata,
        searchType: 'hybrid',
        reranked: useReranking,
      },
    }));

  } catch (error) {
    console.error('Search failed:', error);
    // Fallback to dense search only
    const queryEmbedding = await embedder.embedText(query);
    const results = await vectorDB.similaritySearch(queryEmbedding, topK);
    return results;
  }
}
```

---

## Grading Rubrics

### Multiple Choice Grading

| Score Range | Grade | Description |
|-------------|-------|-------------|
| 90-100% | A | Excellent understanding |
| 80-89% | B | Good understanding |
| 70-79% | C | Satisfactory understanding |
| 60-69% | D | Needs improvement |
| 0-59% | F | Requires remediation |

### Short Answer Grading

| Criteria | Points | Description |
|----------|--------|-------------|
| Completeness | 0-5 | All parts addressed |
| Accuracy | 0-5 | Information correct |
| Depth | 0-5 | Appropriate detail level |
| Examples | 0-5 | Relevant examples provided |
| **Total** | **0-20** | |

### Coding Problem Grading

| Criteria | Points | Description |
|----------|--------|-------------|
| Correctness | 0-40 | All functionality works |
| Error Handling | 0-20 | Edge cases handled |
| Type Safety | 0-20 | Proper TypeScript usage |
| Code Quality | 0-20 | Clean, documented code |
| **Total** | **0-100** | |

---

**[END OF QUIZ AND TEST BANK]**

**Happy assessing! 📝**
