# AI Tutorial Series: Developer Edition
# Quiz and Test Bank with Answer Keys

**A comprehensive assessment resource for the AI Tutorial Series—with quizzes, tests, and answer keys for all 24 modules and 8 capstone projects.**

---

## Table of Contents

1. [How to Use This Test Bank](#how-to-use-this-test-bank)
2. [Phase 1: Understanding How LLMs Actually Work](#phase-1-understanding-how-llms-actually-work)
   - Module 1 Quiz
   - Module 2 Quiz
   - Module 3 Quiz
   - Module 4 Quiz
   - Phase 1 Test
3. [Phase 2: Prompt Engineering & Model APIs](#phase-2-prompt-engineering--model-apis)
   - Module 5 Quiz
   - Module 6 Quiz
   - Module 7 Quiz
   - Module 8 Quiz
   - Phase 2 Test
4. [Phase 3: AI Tool Use & Function Calling](#phase-3-ai-tool-use--function-calling)
   - Module 9 Quiz
   - Module 10 Quiz
   - Module 11 Quiz
   - Phase 3 Test
5. [Phase 4: Retrieval-Augmented Generation (RAG)](#phase-4-retrieval-augmented-generation-rag)
   - Module 12 Quiz
   - Module 13 Quiz
   - Module 14 Quiz
   - Phase 4 Test
6. [Phase 5: Agentic AI Systems](#phase-5-agentic-ai-systems)
   - Module 15 Quiz
   - Module 16 Quiz
   - Module 17 Quiz
   - Phase 5 Test
7. [Phase 6: AI Application Engineering](#phase-6-ai-application-engineering)
   - Module 18 Quiz
   - Module 19 Quiz
   - Module 20 Quiz
   - Module 21 Quiz
   - Phase 6 Test
8. [Phase 7: Production AI Architecture](#phase-7-production-ai-architecture)
   - Module 22 Quiz
   - Module 23 Quiz
   - Module 24 Quiz
   - Phase 7 Test
9. [Capstone Project Assessments](#capstone-project-assessments)
10. [Final Comprehensive Exam](#final-comprehensive-exam)
11. [Answer Keys](#answer-keys)

---

## How to Use This Test Bank

### Assessment Types

| Type | Questions | Time | Difficulty | Purpose |
|------|-----------|------|------------|---------|
| **Module Quiz** | 10 | 15 min | Easy-Medium | Check understanding |
| **Phase Test** | 25 | 45 min | Medium-Hard | Cumulative assessment |
| **Capstone Assessment** | Rubric | 1-3 days | Hard | Project evaluation |
| **Final Exam** | 50 | 90 min | Hard | Comprehensive mastery |

### Scoring Guide

| Grade | Percentage | Performance Level |
|-------|------------|-------------------|
| A | 90-100% | Excellent |
| B | 80-89% | Good |
| C | 70-79% | Satisfactory |
| D | 60-69% | Needs Improvement |
| F | < 60% | Unsatisfactory |

---

## Phase 1: Understanding How LLMs Actually Work

### Module 1 Quiz: Introduction to Generative AI

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is the key innovation introduced in the "Attention Is All You Need" paper?**

A) Recurrent neural networks
B) The Transformer architecture
C) Convolutional neural networks
D) Support vector machines

**2. Which of the following is NOT a major LLM family?**

A) GPT
B) Claude
C) TensorFlow
D) Gemini

**3. What does temperature control in LLM generation?**

A) The speed of generation
B) The randomness/creativity of output
C) The cost of the API call
D) The length of the response

**4. True or False: LLMs "think" and "understand" like humans do.**

A) True
B) False

**5. What is the primary difference between Machine Learning and Deep Learning?**

A) Deep learning uses more data
B) Deep learning uses neural networks with multiple layers
C) Machine learning is older
D) There is no difference

**6. Which model family is known for its focus on safety and reasoning?**

A) GPT
B) Claude
C) Gemini
D) Llama

**7. What role does the system prompt play in LLM interactions?**

A) Sets the persona and behavior of the AI
B) Controls the temperature
C) Specifies the max tokens
D) None of the above

**8. What is the "AI effect"?**

A) The phenomenon where what was once called AI becomes "just software"
B) The effect of AI on the economy
C) The effect of AI on jobs
D) The effect of AI on education

**9. Which company created the GPT family of models?**

A) Anthropic
B) Google
C) Meta
D) OpenAI

**10. What is Generative AI?**

A) AI that classifies existing data
B) AI that creates new content (text, images, audio)
C) AI that analyzes data
D) AI that predicts outcomes

---

### Module 2 Quiz: Tokens & Embeddings

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is a token in the context of LLMs?**

A) A word
B) The smallest unit of text an LLM processes
C) A sentence
D) A paragraph

**2. What is an embedding?**

A) A word in a dictionary
B) A vector (list of numbers) representing meaning
C) A sentence in a document
D) A token in a text

**3. What does cosine similarity measure?**

A) The difference between two numbers
B) The semantic similarity between two vectors
C) The size of two vectors
D) The speed of two operations

**4. Which tokenization algorithm is used by GPT models?**

A) SentencePiece
B) WordPiece
C) BPE (Byte-Pair Encoding)
D) Unicode

**5. What is the approximate token count for 100 English words?**

A) 50 tokens
B) 75 tokens
C) 150 tokens
D) 200 tokens

**6. Which embedding model has 1536 dimensions?**

A) text-embedding-3-large
B) text-embedding-3-small
C) text-embedding-ada-002
D) Both B and C

**7. What is the formula for cosine similarity?**

A) (A · B) / (||A|| × ||B||)
B) (A + B) / (A - B)
C) A · B
D) ||A - B||

**8. What range does cosine similarity typically have?**

A) 0 to 1
B) -1 to 1
C) 0 to 100
D) -100 to 100

**9. What is the approximate cost per 1M tokens for text-embedding-3-small?**

A) $0.02
B) $0.13
C) $0.50
D) $1.00

**10. What is the relationship between similar texts in embedding space?**

A) Their vectors are far apart
B) Their vectors are close together
C) Their vectors are perpendicular
D) Their vectors are identical

---

### Module 3 Quiz: How LLM Inference Works

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is next-token prediction?**

A) The process of predicting the next word in a sequence
B) The process of predicting the next sentence
C) The process of predicting the next document
D) The process of predicting the next token based on previous tokens

**2. What happens when temperature = 0?**

A) Output is completely random
B) Output is deterministic (greedy)
C) Output is creative
D) Output is nonsensical

**3. What is Top-K?**

A) Consider only the K most likely tokens
B) Consider all tokens
C) Consider only the first K tokens
D) Consider only the last K tokens

**4. What is Top-P (Nucleus Sampling)?**

A) Consider only the P% most likely tokens
B) Consider tokens until cumulative probability reaches P%
C) Consider only the first P tokens
D) Consider only the last P tokens

**5. What is a hallucination?**

A) When the model generates correct information
B) When the model generates incorrect information confidently
C) When the model fails to generate anything
D) When the model generates random text

**6. Which temperature is best for factual Q&A?**

A) 0.0
B) 0.3
C) 0.7
D) 1.5

**7. What are logits?**

A) The final output of the model
B) Raw scores before softmax
C) Probabilities
D) Tokens

**8. What does softmax do?**

A) Converts logits to probabilities
B) Converts probabilities to logits
C) Converts tokens to embeddings
D) Converts embeddings to tokens

**9. Which parameter would you adjust to reduce hallucinations?**

A) Lower temperature
B) Higher temperature
C) Higher Top-K
D) Higher Top-P

**10. What is the relationship between temperature and entropy?**

A) Higher temperature = higher entropy (more random)
B) Higher temperature = lower entropy (less random)
C) No relationship
D) Temperature controls speed, not randomness

---

### Module 4 Quiz: Context Windows & Memory

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is a context window?**

A) The maximum number of tokens an LLM can process
B) A window in the user interface
C) A programming library
D) A type of prompt

**2. What happens when you exceed the context window?**

A) The model continues processing
B) The request is rejected or truncated
C) The model becomes faster
D) Nothing happens

**3. Which model has the largest context window?**

A) GPT-3.5
B) GPT-4
C) Claude 3.5
D) Gemini 1.5

**4. What is the context window of GPT-4o-mini?**

A) 8,192 tokens
B) 16,384 tokens
C) 128,000 tokens
D) 2,000,000 tokens

**5. What is truncation as a memory management strategy?**

A) Dropping oldest messages
B) Keeping only recent messages
C) Summarizing old messages
D) Using a vector database

**6. What is a sliding window in memory management?**

A) Dropping oldest messages
B) Keeping system prompt + recent messages
C) Summarizing old messages
D) Using a vector database

**7. How many tokens are roughly equivalent to 300 pages of text?**

A) 8,192 tokens
B) 16,384 tokens
C) 128,000 tokens
D) 2,000,000 tokens

**8. What is hierarchical memory?**

A) Multiple levels of memory (STM, LTM, etc.)
B) Dropping oldest messages
C) Keeping only recent messages
D) Summarizing old messages

**9. What is the approximate token-to-character ratio in English?**

A) 1 token ≈ 1 character
B) 1 token ≈ 4 characters
C) 1 token ≈ 10 characters
D) 1 token ≈ 100 characters

**10. Why is memory management important for long conversations?**

A) To prevent the API from crashing
B) To stay within the context window and preserve key information
C) To make the model faster
D) To reduce costs

---

### Phase 1 Test: Understanding How LLMs Actually Work

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. Which of the following is NOT a major LLM family?**

A) GPT
B) Claude
C) TensorFlow
D) Gemini

**2. What is an embedding?**

A) A word in a dictionary
B) A vector representing meaning
C) A sentence in a document
D) A token in a text

**3. What does temperature = 0.0 produce?**

A) Completely random output
B) Deterministic (greedy) output
C) Creative output
D) Nonsensical output

**4. What is the context window of Claude 3.5?**

A) 16,384 tokens
B) 128,000 tokens
C) 200,000 tokens
D) 2,000,000 tokens

**5. What does cosine similarity measure?**

A) The difference between two numbers
B) The semantic similarity between two vectors
C) The size of two vectors
D) The speed of two operations

**6. What is the Transformer architecture known for?**

A) Processing text sequentially
B) Processing all tokens simultaneously with attention
C) Processing images only
D) Processing audio only

**7. What is the typical relationship between token count and cost?**

A) More tokens = higher cost
B) More tokens = lower cost
C) No relationship
D) Higher cost = fewer tokens

**8. Which tokenization algorithm is used by Gemini?**

A) BPE
B) SentencePiece
C) WordPiece
D) Unicode

**9. What is a hallucination?**

A) When the model generates correct information
B) When the model generates incorrect information confidently
C) When the model fails to generate anything
D) When the model generates random text

**10. What is the approximate token count for 100 English words?**

A) 50 tokens
B) 75 tokens
C) 150 tokens
D) 200 tokens

**11. What does Top-P (Nucleus Sampling) do?**

A) Consider only the P% most likely tokens
B) Consider tokens until cumulative probability reaches P%
C) Consider only the first P tokens
D) Consider only the last P tokens

**12. Which model family is known for being open-source?**

A) GPT
B) Claude
C) Gemini
D) Llama

**13. What is the role of attention in Transformers?**

A) To speed up processing
B) To understand relationships between tokens
C) To reduce costs
D) To increase token count

**14. What is the default temperature in most LLM APIs?**

A) 0.0
B) 0.7
C) 1.0
D) 1.5

**15. Which memory management strategy is most expensive (calls LLM)?**

A) Truncation
B) Sliding window
C) Summarization
D) All are equally expensive

---

**Section B: Short Answer (5 questions)**

**16. Explain what a context window is and why it's important.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between tokens and words?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. Explain how temperature, Top-K, and Top-P work together.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. What are embeddings and why are they important for AI?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. Describe three memory management strategies for long conversations.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Write code to generate an embedding for a text.**

```python
# Your code here
```

**22. Write code to count tokens in a text.**

```python
# Your code here
```

**23. Write code for a simple chatbot with conversation history.**

```python
# Your code here
```

**24. What would happen if you sent 200,000 tokens to GPT-4o-mini?**

```
________________________________________________________________________
________________________________________________________________________
```

**25. What parameters would you choose for a factual Q&A system and why?**

```
________________________________________________________________________
________________________________________________________________________
```

---

## Phase 2: Prompt Engineering & Model APIs

### Module 5 Quiz: AI APIs

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. Which provider uses the authentication header `x-api-key`?**

A) OpenAI
B) Anthropic
C) Google
D) Ollama

**2. What is the purpose of rate limiting?**

A) To increase speed
B) To prevent overwhelming the API
C) To reduce costs
D) To improve quality

**3. Which model has the lowest cost per 1M tokens?**

A) gpt-4o
B) gpt-4o-mini
C) claude-3.5-sonnet
D) gemini-1.5-pro

**4. True or False: Ollama is a free, local AI provider.**

A) True
B) False

**5. What does HTTP status code 429 indicate?**

A) Success
B) Rate limit exceeded
C) Server error
D) Invalid API key

**6. Which provider offers a 2,000,000 token context window?**

A) OpenAI
B) Anthropic
C) Google Gemini
D) Ollama

**7. What is the format of an OpenAI API key?**

A) sk-...
B) sk-ant-...
C) AIza...
D) Bearer token

**8. What is streaming in the context of AI APIs?**

A) Sending data in chunks for real-time display
B) Sending all data at once
C) Sending data in batches
D) Sending data in compressed format

**9. What is the cost of gpt-4o-mini output tokens per 1M?**

A) $0.150
B) $0.600
C) $5.00
D) $15.00

**10. Which of the following is a valid cost optimization strategy?**

A) Using the most expensive model for all tasks
B) Caching identical requests
C) Never using caching
D) Using the largest context window always

---

### Module 6 Quiz: Prompt Engineering Fundamentals

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is a system prompt?**

A) The user's question
B) Instructions defining the AI's persona and behavior
C) The AI's response
D) The API endpoint

**2. What is Chain-of-Thought prompting?**

A) Asking the AI to show its reasoning step by step
B) Asking the AI to be creative
C) Asking the AI to be concise
D) Asking the AI to generate code

**3. What is few-shot learning?**

A) Training the model from scratch
B) Providing examples in the prompt
C) Using a pre-trained model
D) Fine-tuning the model

**4. Which technique generates multiple responses and takes the most consistent one?**

A) Chain-of-Thought
B) Self-Consistency
C) Few-shot learning
D) Role prompting

**5. What are the three elements of a good prompt?**

A) Role, Task, Conditions
B) System, User, Assistant
C) Input, Output, Format
D) Temperature, Top-K, Top-P

**6. What is role prompting?**

A) Giving the AI a specific persona
B) Giving the AI a specific task
C) Giving the AI a specific format
D) Giving the AI a specific temperature

**7. When would you use Chain-of-Thought prompting?**

A) For creative writing
B) For math and logic problems
C) For simple factual questions
D) For image generation

**8. What is a prompt template?**

A) A reusable prompt structure with variables
B) A specific prompt for a specific task
C) A random prompt
D) A prompt with no variables

**9. What is the difference between zero-shot and few-shot learning?**

A) Zero-shot has examples; few-shot does not
B) Few-shot has examples; zero-shot does not
C) They are the same
D) Zero-shot uses more data

**10. Why is self-consistency effective?**

A) It generates more creative responses
B) It finds consensus, reducing the chance of hallucination
C) It generates faster responses
D) It generates shorter responses

---

### Module 7 Quiz: Structured Outputs

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is the most common format for structured outputs?**

A) XML
B) JSON
C) HTML
D) CSV

**2. What is JSON Schema used for?**

A) Generating JSON
B) Validating JSON structure
C) Parsing JSON
D) Converting JSON to XML

**3. What is JSON Mode in OpenAI?**

A) A mode that enforces JSON output
B) A mode that disables JSON output
C) A mode that generates XML
D) A mode that generates HTML

**4. What is the purpose of response_format in the OpenAI API?**

A) To specify the temperature
B) To specify the output format (e.g., JSON)
C) To specify the input format
D) To specify the model

**5. True or False: Structured outputs always require JSON Schema validation.**

A) True
B) False

**6. What is a common use case for structured outputs?**

A) Creative writing
B) Data extraction and automation
C) Image generation
D) Audio transcription

**7. What type of validation does JSON Schema provide?**

A) Type checking
B) Required fields
C) Format validation (email, date)
D) All of the above

**8. What is the best temperature for structured output generation?**

A) High temperature (1.0+)
B) Low temperature (0.0-0.3)
C) Medium temperature (0.5-0.7)
D) Temperature doesn't matter

**9. What field in JSON Schema specifies which properties are required?**

A) "properties"
B) "required"
C) "type"
D) "enum"

**10. How do you handle JSON parsing errors?**

A) Ignore them
B) Use try/except and attempt recovery
C) Crash the program
D) Return empty JSON

---

### Module 8 Quiz: Multimodal AI

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is multimodal AI?**

A) AI that processes text only
B) AI that processes multiple data types (text, images, audio)
C) AI that processes audio only
D) AI that processes images only

**2. Which model can process images and text?**

A) gpt-4o-mini
B) gpt-4o (vision version)
C) claude-3.5-sonnet
D) All of the above

**3. What does OCR stand for?**

A) Optical Character Recognition
B) Original Content Recognition
C) Online Character Recognition
D) Optical Code Recognition

**4. Which OpenAI model is used for speech-to-text?**

A) Whisper
B) DALL-E
C) TTS-1
D) GPT-4

**5. What is the purpose of image generation?**

A) To analyze images
B) To create images from text descriptions
C) To extract text from images
D) To classify images

**6. What is the format for embedding images in an API call?**

A) Raw bytes
B) Base64 encoded data
C) URL
D) Both B and C

**7. Which of the following is NOT a multimodal capability?**

A) Image understanding
B) Audio transcription
C) Text classification
D) Image generation

**8. What is the primary use case for speech-to-text?**

A) Creating images
B) Transcribing audio to text
C) Generating audio from text
D) Analyzing images

**9. What is the primary use case for text-to-speech?**

A) Creating images
B) Transcribing audio to text
C) Generating audio from text
D) Analyzing images

**10. What is the vision capability of multimodal models?**

A) Analyzing and understanding images
B) Generating images
C) Extracting text from images
D) All of the above

---

### Phase 2 Test: Prompt Engineering & Model APIs

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. Which provider uses the authentication header `x-api-key`?**

A) OpenAI
B) Anthropic
C) Google
D) Ollama

**2. What is a system prompt?**

A) The user's question
B) Instructions defining the AI's persona and behavior
C) The AI's response
D) The API endpoint

**3. What is Chain-of-Thought prompting?**

A) Asking the AI to show its reasoning step by step
B) Asking the AI to be creative
C) Asking the AI to be concise
D) Asking the AI to generate code

**4. What is the most common format for structured outputs?**

A) XML
B) JSON
C) HTML
D) CSV

**5. What is the purpose of response_format in the OpenAI API?**

A) To specify the temperature
B) To specify the output format (e.g., JSON)
C) To specify the input format
D) To specify the model

**6. Which model has the lowest cost per 1M tokens?**

A) gpt-4o
B) gpt-4o-mini
C) claude-3.5-sonnet
D) gemini-1.5-pro

**7. What is the format of an OpenAI API key?**

A) sk-...
B) sk-ant-...
C) AIza...
D) Bearer token

**8. What is few-shot learning?**

A) Training the model from scratch
B) Providing examples in the prompt
C) Using a pre-trained model
D) Fine-tuning the model

**9. What is the purpose of rate limiting?**

A) To increase speed
B) To prevent overwhelming the API
C) To reduce costs
D) To improve quality

**10. Which model is used for speech-to-text?**

A) Whisper
B) DALL-E
C) TTS-1
D) GPT-4

**11. What is a prompt template?**

A) A reusable prompt structure with variables
B) A specific prompt for a specific task
C) A random prompt
D) A prompt with no variables

**12. What does OCR stand for?**

A) Optical Character Recognition
B) Original Content Recognition
C) Online Character Recognition
D) Optical Code Recognition

**13. Which technique generates multiple responses and takes the most consistent one?**

A) Chain-of-Thought
B) Self-Consistency
C) Few-shot learning
D) Role prompting

**14. What is the purpose of JSON Schema validation?**

A) To ensure data quality and structure
B) To speed up generation
C) To reduce cost
D) To increase creativity

**15. What is the vision capability of multimodal models?**

A) Analyzing and understanding images
B) Generating images
C) Extracting text from images
D) All of the above

---

**Section B: Short Answer (5 questions)**

**16. Explain the difference between zero-shot and few-shot learning.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between a system prompt and a user prompt?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. Explain how to ensure structured output from an LLM.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. What are the benefits of streaming responses?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. Describe the different modalities in multimodal AI.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Write a prompt that uses Chain-of-Thought to solve a math problem.**

```python
# Your code here
```

**22. Write code to generate a JSON response with schema validation.**

```python
# Your code here
```

**23. Write a system prompt for a technical expert persona.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**24. Write code to analyze an image using a multimodal model.**

```python
# Your code here
```

**25. Design a prompt for extracting structured data from emails.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

## Phase 3: AI Tool Use & Function Calling

### Module 9 Quiz: Function Calling

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is function calling in the context of LLMs?**

A) A feature that allows LLMs to call external functions
B) A way to call functions within the LLM
C) A way to call APIs
D) A way to call databases

**2. What is a tool schema?**

A) A description of the tool's implementation
B) A JSON description of the tool's parameters and purpose
C) A Python class
D) A database schema

**3. Which field in the tool schema describes what the tool does?**

A) "type"
B) "name"
C) "description"
D) "parameters"

**4. What is the role of the handler in a tool?**

A) To describe the tool
B) To execute the tool's functionality
C) To validate the tool's arguments
D) To log the tool's usage

**5. What happens when an LLM decides to call a function?**

A) The LLM generates a function call with arguments
B) The LLM executes the function directly
C) The LLM ignores the function
D) The LLM generates a response without the function

**6. What is the purpose of argument validation?**

A) To ensure the function is called correctly
B) To speed up execution
C) To reduce cost
D) To improve creativity

**7. What is the format of tool calls in the OpenAI API?**

A) JSON object with "name" and "arguments"
B) Plain text
C) XML
D) CSV

**8. Which of the following is a valid use case for function calling?**

A) Getting weather data
B) Performing calculations
C) Querying a database
D) All of the above

**9. What is the role of a tool registry?**

A) To store and manage tools
B) To execute tools
C) To validate tools
D) To describe tools

**10. How should you handle tool execution errors?**

A) Ignore them
B) Return an error message to the LLM
C) Crash the program
D) Log them silently

---

### Module 10 Quiz: Tool Orchestration

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is tool orchestration?**

A) Coordinating multiple tools to achieve a goal
B) Using a single tool
C) Writing tools
D) Testing tools

**2. What is sequential execution?**

A) Tools run simultaneously
B) Tools run one after another
C) Tools run randomly
D) Tools run in any order

**3. What is parallel execution?**

A) Tools run simultaneously
B) Tools run one after another
C) Tools run randomly
D) Tools run in any order

**4. How do you pass data between sequential steps?**

A) Through a global variable
B) Through the context/state
C) Through the API
D) Through the database

**5. What is a workflow?**

A) A sequence of steps to achieve a goal
B) A single step
C) A random sequence
D) A database query

**6. What is the purpose of dependency management?**

A) To ensure steps execute in the correct order
B) To speed up execution
C) To reduce cost
D) To improve creativity

**7. What is error recovery in orchestration?**

A) Ignoring errors
B) Handling failures with retries and fallbacks
C) Stopping on any error
D) Logging errors

**8. What is a conditional step in a workflow?**

A) A step that always executes
B) A step that executes based on a condition
C) A step that never executes
D) A step that executes in parallel

**9. Which of the following is a benefit of parallel execution?**

A) Faster execution when tasks are independent
B) Reduced cost
C) Improved quality
D) Simplified code

**10. What is a loop step in a workflow?**

A) A step that executes once
B) A step that executes repeatedly until a condition is met
C) A step that executes in parallel
D) A step that never executes

---

### Module 11 Quiz: Model Context Protocol (MCP)

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is MCP?**

A) A protocol for AI-tool integration
B) A programming language
C) A database
D) A cloud service

**2. What is the purpose of MCP?**

A) To standardize AI-tool integration
B) To provide a new LLM
C) To replace APIs
D) To provide a database

**3. Which of the following is a component of MCP?**

A) Resources
B) Prompts
C) Tools
D) All of the above

**4. What are MCP resources?**

A) Data and content that the server provides
B) Prompt templates
C) Executable functions
D) API endpoints

**5. What are MCP prompts?**

A) Data and content
B) Reusable prompt templates
C) Executable functions
D) API endpoints

**6. What are MCP tools?**

A) Data and content
B) Reusable prompt templates
C) Executable functions
D) API endpoints

**7. What transports does MCP support?**

A) Stdio
B) SSE
C) WebSocket
D) All of the above

**8. What is the role of the MCP server?**

A) To connect to clients
B) To expose capabilities
C) To execute functions
D) All of the above

**9. What is the role of the MCP client?**

A) To connect to servers and use capabilities
B) To expose capabilities
C) To execute functions
D) To provide resources

**10. What security considerations are important for MCP?**

A) Authentication
B) Authorization
C) Data privacy
D) All of the above

---

### Phase 3 Test: AI Tool Use & Function Calling

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. What is function calling in the context of LLMs?**

A) A feature that allows LLMs to call external functions
B) A way to call functions within the LLM
C) A way to call APIs
D) A way to call databases

**2. What is a tool schema?**

A) A description of the tool's implementation
B) A JSON description of the tool's parameters and purpose
C) A Python class
D) A database schema

**3. What is the role of the handler in a tool?**

A) To describe the tool
B) To execute the tool's functionality
C) To validate the tool's arguments
D) To log the tool's usage

**4. What is sequential execution?**

A) Tools run simultaneously
B) Tools run one after another
C) Tools run randomly
D) Tools run in any order

**5. What is parallel execution?**

A) Tools run simultaneously
B) Tools run one after another
C) Tools run randomly
D) Tools run in any order

**6. What is a workflow?**

A) A sequence of steps to achieve a goal
B) A single step
C) A random sequence
D) A database query

**7. What is the purpose of dependency management?**

A) To ensure steps execute in the correct order
B) To speed up execution
C) To reduce cost
D) To improve creativity

**8. What is MCP?**

A) A protocol for AI-tool integration
B) A programming language
C) A database
D) A cloud service

**9. Which of the following is a component of MCP?**

A) Resources
B) Prompts
C) Tools
D) All of the above

**10. What are MCP resources?**

A) Data and content that the server provides
B) Prompt templates
C) Executable functions
D) API endpoints

**11. What are MCP prompts?**

A) Data and content
B) Reusable prompt templates
C) Executable functions
D) API endpoints

**12. What transports does MCP support?**

A) Stdio
B) SSE
C) WebSocket
D) All of the above

**13. What is error recovery in orchestration?**

A) Ignoring errors
B) Handling failures with retries and fallbacks
C) Stopping on any error
D) Logging errors

**14. What is the purpose of argument validation?**

A) To ensure the function is called correctly
B) To speed up execution
C) To reduce cost
D) To improve creativity

**15. What security considerations are important for MCP?**

A) Authentication
B) Authorization
C) Data privacy
D) All of the above

---

**Section B: Short Answer (5 questions)**

**16. Explain the function calling flow from user query to response.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between sequential and parallel execution?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. What are the three main capabilities of MCP?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. How do you handle errors in tool orchestration?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. What are the benefits of using MCP?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Define a tool schema for a calculator function.**

```json
# Your code here
```

**22. Write code to orchestrate a workflow with sequential steps.**

```python
# Your code here
```

**23. Write a simple MCP server with one resource and one tool.**

```python
# Your code here
```

**24. Describe how to handle a failed tool execution.**

```
________________________________________________________________________
________________________________________________________________________
```

**25. Design a tool registry and explain how it works.**

```
________________________________________________________________________
________________________________________________________________________
```

---

## Phase 4: Retrieval-Augmented Generation (RAG)

### Module 12 Quiz: Embeddings & Vector Databases

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is the purpose of chunking?**

A) To split documents into smaller pieces for embedding
B) To combine documents
C) To delete documents
D) To compress documents

**2. Which chunking strategy is most semantically coherent?**

A) Fixed size
B) Sentence
C) Semantic
D) Paragraph

**3. What is a vector database?**

A) A database for storing vectors
B) A database for storing text
C) A database for storing images
D) A database for storing audio

**4. Which of the following is a vector database?**

A) Chroma
B) Pinecone
C) FAISS
D) All of the above

**5. What is the relationship between chunk size and retrieval precision?**

A) Smaller chunks = higher precision
B) Larger chunks = higher precision
C) No relationship
D) Chunk size affects speed, not precision

**6. What is the recommended chunk overlap?**

A) 0%
B) 10-20%
C) 50%
D) 100%

**7. Which vector database is best for development?**

A) Pinecone
B) Chroma
C) Weaviate
D) Milvus

**8. What is the purpose of metadata in vector databases?**

A) To store the vector
B) To filter and organize search results
C) To speed up the search
D) To reduce storage size

**9. Which embedding model has 3072 dimensions?**

A) text-embedding-3-small
B) text-embedding-3-large
C) text-embedding-ada-002
D) BAAI/bge-large-en-v1.5

**10. What is the trade-off between chunk size and token usage?**

A) Larger chunks = more tokens = higher cost
B) Larger chunks = fewer tokens = lower cost
C) No relationship
D) Chunk size affects speed, not cost

---

### Module 13 Quiz: Building a RAG Pipeline

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What are the stages of a RAG pipeline?**

A) Ingestion, Retrieval, Generation
B) Training, Validation, Testing
C) Collection, Processing, Analysis
D) Input, Processing, Output

**2. What is the purpose of document ingestion in RAG?**

A) To process and store documents
B) To retrieve documents
C) To generate responses
D) To train the model

**3. What is the purpose of retrieval in RAG?**

A) To process and store documents
B) To find relevant information for queries
C) To generate responses
D) To train the model

**4. What is the purpose of generation in RAG?**

A) To process and store documents
B) To retrieve documents
C) To produce accurate, cited responses
D) To train the model

**5. Why are citations important in RAG?**

A) To build trust and enable verification
B) To speed up generation
C) To reduce cost
D) To improve creativity

**6. What is context construction in RAG?**

A) Building the prompt with retrieved sources
B) Retrieving documents
C) Generating responses
D) Processing documents

**7. What is the role of the vector database in RAG?**

A) To store and search embeddings
B) To generate responses
C) To process documents
D) To train the model

**8. How does RAG reduce hallucinations?**

A) By grounding responses in external knowledge
B) By increasing temperature
C) By using a larger model
D) By reducing token count

**9. What is the recommended Top-K for RAG retrieval?**

A) 1-2
B) 3-5
C) 10-20
D) 50-100

**10. What is the relationship between retrieved documents and response quality?**

A) More relevant documents = higher quality
B) Fewer documents = higher quality
C) No relationship
D) Documents don't affect quality

---

### Module 14 Quiz: Advanced RAG

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is hybrid search?**

A) Combining keyword and semantic search
B) Combining two semantic searches
C) Combining two keyword searches
D) Combining search with generation

**2. What is context compression?**

A) Summarizing retrieved chunks
B) Compressing the model
C) Reducing the temperature
D) Increasing the context window

**3. What is parent-child retrieval?**

A) Retrieving small chunks (children) but returning large chunks (parents)
B) Retrieving only large chunks
C) Retrieving only small chunks
D) Retrieving random chunks

**4. What is a knowledge graph?**

A) A graph of relationships between entities
B) A vector database
C) A prompt template
D) A tool registry

**5. How does hybrid search improve recall?**

A) By finding both exact matches and semantic matches
B) By using a larger model
C) By increasing the temperature
D) By reducing the chunk size

**6. What is the purpose of re-ranking in RAG?**

A) To optimize retrieval order
B) To generate responses
C) To process documents
D) To train the model

**7. What is query expansion?**

A) Adding related terms to the query
B) Expanding the context window
C) Expanding the model
D) Expanding the dataset

**8. How does parent-child retrieval improve context?**

A) By providing larger chunks with more context
B) By using smaller chunks
C) By using random chunks
D) By using fewer chunks

**9. What is the relationship between compression and token usage?**

A) Compression reduces token usage
B) Compression increases token usage
C) No relationship
D) Compression affects speed, not tokens

**10. What is the purpose of RAG optimization?**

A) To fine-tune retrieval parameters
B) To train the model
C) To process documents
D) To generate responses

---

### Phase 4 Test: Retrieval-Augmented Generation (RAG)

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. What is the purpose of chunking?**

A) To split documents into smaller pieces for embedding
B) To combine documents
C) To delete documents
D) To compress documents

**2. Which chunking strategy is most semantically coherent?**

A) Fixed size
B) Sentence
C) Semantic
D) Paragraph

**3. Which of the following is a vector database?**

A) Chroma
B) Pinecone
C) FAISS
D) All of the above

**4. What are the stages of a RAG pipeline?**

A) Ingestion, Retrieval, Generation
B) Training, Validation, Testing
C) Collection, Processing, Analysis
D) Input, Processing, Output

**5. Why are citations important in RAG?**

A) To build trust and enable verification
B) To speed up generation
C) To reduce cost
D) To improve creativity

**6. What is the role of the vector database in RAG?**

A) To store and search embeddings
B) To generate responses
C) To process documents
D) To train the model

**7. What is hybrid search?**

A) Combining keyword and semantic search
B) Combining two semantic searches
C) Combining two keyword searches
D) Combining search with generation

**8. What is parent-child retrieval?**

A) Retrieving small chunks (children) but returning large chunks (parents)
B) Retrieving only large chunks
C) Retrieving only small chunks
D) Retrieving random chunks

**9. What is a knowledge graph?**

A) A graph of relationships between entities
B) A vector database
C) A prompt template
D) A tool registry

**10. What is the purpose of re-ranking in RAG?**

A) To optimize retrieval order
B) To generate responses
C) To process documents
D) To train the model

**11. What is the recommended chunk overlap?**

A) 0%
B) 10-20%
C) 50%
D) 100%

**12. How does RAG reduce hallucinations?**

A) By grounding responses in external knowledge
B) By increasing temperature
C) By using a larger model
D) By reducing token count

**13. What is context compression?**

A) Summarizing retrieved chunks
B) Compressing the model
C) Reducing the temperature
D) Increasing the context window

**14. What is the recommended Top-K for RAG retrieval?**

A) 1-2
B) 3-5
C) 10-20
D) 50-100

**15. What is the purpose of RAG optimization?**

A) To fine-tune retrieval parameters
B) To train the model
C) To process documents
D) To generate responses

---

**Section B: Short Answer (5 questions)**

**16. Explain the RAG pipeline in 3-5 sentences.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between hybrid search and pure semantic search?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. Explain how parent-child retrieval works and why it's useful.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. What are the key factors that affect RAG quality?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. How would you optimize a RAG system for better performance?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Write code to chunk a document using a recursive strategy.**

```python
# Your code here
```

**22. Write code to implement a simple RAG pipeline.**

```python
# Your code here
```

**23. Design a hybrid search system and explain its components.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**24. Write code to implement a vector store with similarity search.**

```python
# Your code here
```

**25. Describe how to add citations to a RAG response.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

## Phase 5: Agentic AI Systems

### Module 15 Quiz: AI Agents

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What makes an AI agent different from a simple chatbot?**

A) Agents can plan, reason, and take autonomous action
B) Agents are faster
C) Agents are cheaper
D) Agents use smaller models

**2. What are the key components of an AI agent?**

A) Planning, Reasoning, Memory, Tool Use, Reflection
B) Input, Output, Processing
C) Training, Validation, Testing
D) Collection, Processing, Analysis

**3. What is the purpose of planning in an agent?**

A) To break down goals into actionable steps
B) To generate responses
C) To process data
D) To train the model

**4. What is reflection in the context of AI agents?**

A) Self-evaluation and improvement
B) Generating responses
C) Processing data
D) Training the model

**5. What is goal decomposition?**

A) Breaking down a complex goal into sub-goals
B) Combining multiple goals
C) Deleting goals
D) Ignoring goals

**6. Which framework is known for graph-based agent workflows?**

A) LangGraph
B) AutoGen
C) CrewAI
D) Semantic Kernel

**7. What is the role of memory in AI agents?**

A) To store and recall information
B) To generate responses
C) To process data
D) To train the model

**8. What is the purpose of reflection in agents?**

A) To improve performance through self-evaluation
B) To generate responses
C) To process data
D) To train the model

**9. Which of the following is a type of agent?**

A) Reactive
B) Proactive
C) Collaborative
D) All of the above

**10. What is the difference between a reactive and proactive agent?**

A) Reactive responds to events; proactive takes initiative
B) Reactive takes initiative; proactive responds to events
C) They are the same
D) Reactive is faster

---

### Module 16 Quiz: Multi-Agent Systems

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is a multi-agent system?**

A) A system with multiple AI agents
B) A system with one AI agent
C) A system with no AI agents
D) A system with only humans

**2. What is the role of a coordinator agent?**

A) To plan and delegate tasks
B) To execute tasks
C) To generate responses
D) To process data

**3. What is the role of a worker agent?**

A) To execute specific tasks
B) To plan and delegate
C) To generate responses
D) To process data

**4. Which communication pattern involves a coordinator?**

A) Hierarchical
B) Peer-to-peer
C) Broadcast
D) Swarm

**5. What is a swarm architecture?**

A) Decentralized collaboration
B) Centralized coordination
C) Single agent
D) No communication

**6. What is the purpose of agent-to-agent communication?**

A) To coordinate and collaborate
B) To compete
C) To ignore each other
D) To process data

**7. Which framework is known for multi-agent conversations?**

A) AutoGen
B) LangGraph
C) CrewAI
D) Semantic Kernel

**8. What is the difference between hierarchical and swarm architectures?**

A) Hierarchical has a coordinator; swarm is decentralized
B) Swarm has a coordinator; hierarchical is decentralized
C) They are the same
D) Hierarchical is faster

**9. What is the purpose of consensus strategies in multi-agent systems?**

A) To agree on decisions
B) To compete
C) To ignore each other
D) To process data

**10. When would you use a hierarchical team structure?**

A) When clear structure and defined roles are needed
B) When no structure is needed
C) When roles are unclear
D) When agents should be independent

---

### Module 17 Quiz: Agent Memory

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What are the four types of memory in AI agents?**

A) Short-term, Long-term, Episodic, Semantic
B) Short-term, Long-term, Working, Permanent
C) Immediate, Recent, Past, Permanent
D) Current, History, Future, Permanent

**2. What is short-term memory in an agent?**

A) Recent context and immediate state
B) Permanent knowledge
C) Specific events
D) General facts

**3. What is long-term memory in an agent?**

A) Recent context and immediate state
B) Persistent knowledge storage
C) Specific events
D) General facts

**4. What is episodic memory in an agent?**

A) Recent context and immediate state
B) Persistent knowledge storage
C) Specific events and interactions
D) General facts

**5. What is semantic memory in an agent?**

A) Recent context and immediate state
B) Persistent knowledge storage
C) Specific events
D) General knowledge and concepts

**6. What is memory consolidation?**

A) Moving memories from short-term to long-term
B) Deleting memories
C) Adding memories
D) Retrieving memories

**7. What is memory pruning?**

A) Removing old or irrelevant memories
B) Adding new memories
C) Retrieving memories
D) Moving memories

**8. Which memory retrieval strategy uses semantic similarity?**

A) Relevance-based retrieval
B) Recency-based retrieval
C) Frequency-based retrieval
D) Temporal-based retrieval

**9. What is the purpose of memory in agents?**

A) To enable learning and recall
B) To generate responses
C) To process data
D) To train the model

**10. When would you prune memories?**

A) When memory is full or irrelevant
B) Never
C) Always
D) Only at the start

---

### Phase 5 Test: Agentic AI Systems

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. What makes an AI agent different from a simple chatbot?**

A) Agents can plan, reason, and take autonomous action
B) Agents are faster
C) Agents are cheaper
D) Agents use smaller models

**2. What are the key components of an AI agent?**

A) Planning, Reasoning, Memory, Tool Use, Reflection
B) Input, Output, Processing
C) Training, Validation, Testing
D) Collection, Processing, Analysis

**3. What is the purpose of planning in an agent?**

A) To break down goals into actionable steps
B) To generate responses
C) To process data
D) To train the model

**4. What is a multi-agent system?**

A) A system with multiple AI agents
B) A system with one AI agent
C) A system with no AI agents
D) A system with only humans

**5. What is the role of a coordinator agent?**

A) To plan and delegate tasks
B) To execute tasks
C) To generate responses
D) To process data

**6. What is the role of a worker agent?**

A) To execute specific tasks
B) To plan and delegate
C) To generate responses
D) To process data

**7. Which communication pattern involves a coordinator?**

A) Hierarchical
B) Peer-to-peer
C) Broadcast
D) Swarm

**8. What are the four types of memory in AI agents?**

A) Short-term, Long-term, Episodic, Semantic
B) Short-term, Long-term, Working, Permanent
C) Immediate, Recent, Past, Permanent
D) Current, History, Future, Permanent

**9. What is short-term memory in an agent?**

A) Recent context and immediate state
B) Permanent knowledge
C) Specific events
D) General facts

**10. What is long-term memory in an agent?**

A) Recent context and immediate state
B) Persistent knowledge storage
C) Specific events
D) General facts

**11. What is reflection in the context of AI agents?**

A) Self-evaluation and improvement
B) Generating responses
C) Processing data
D) Training the model

**12. What is goal decomposition?**

A) Breaking down a complex goal into sub-goals
B) Combining multiple goals
C) Deleting goals
D) Ignoring goals

**13. What is a swarm architecture?**

A) Decentralized collaboration
B) Centralized coordination
C) Single agent
D) No communication

**14. What is memory consolidation?**

A) Moving memories from short-term to long-term
B) Deleting memories
C) Adding memories
D) Retrieving memories

**15. What is memory pruning?**

A) Removing old or irrelevant memories
B) Adding new memories
C) Retrieving memories
D) Moving memories

---

**Section B: Short Answer (5 questions)**

**16. Describe the agent cycle in 3-5 sentences.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between short-term and long-term memory?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. Explain the difference between hierarchical and swarm architectures.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. What is the purpose of reflection in agents?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. How does memory consolidation work?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Write a simple agent class with planning and execution.**

```python
# Your code here
```

**22. Write a coordinator agent that delegates tasks to workers.**

```python
# Your code here
```

**23. Implement a memory system with short-term and long-term memory.**

```python
# Your code here
```

**24. Design a multi-agent system for research and report writing.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**25. Describe how to implement reflection in an agent.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

## Phase 6: AI Application Engineering

### Module 18 Quiz: Asynchronous AI Programming

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is asynchronous programming?**

A) A programming model that allows non-blocking operations
B) A programming model that blocks operations
C) A programming model that uses only one thread
D) A programming model that ignores I/O

**2. What is the difference between synchronous and asynchronous?**

A) Sync blocks; async doesn't
B) Async blocks; sync doesn't
C) They are the same
D) Sync is faster

**3. What is streaming in the context of AI APIs?**

A) Receiving data in chunks for real-time display
B) Receiving all data at once
C) Receiving data in batches
D) Receiving compressed data

**4. What is Server-Sent Events (SSE)?**

A) A technology for sending real-time updates from server to client
B) A technology for sending updates from client to server
C) A technology for batch processing
D) A technology for compression

**5. What is the purpose of WebSockets?**

A) Bidirectional, real-time communication
B) One-way communication
C) Batch processing
D) Compression

**6. What is asyncio in Python?**

A) A library for asynchronous programming
B) A library for synchronous programming
C) A library for data processing
D) A library for compression

**7. What is the role of the semaphore in async programming?**

A) To limit concurrent operations
B) To speed up operations
C) To reduce cost
D) To improve quality

**8. What is the benefit of concurrent processing?**

A) Handling multiple requests simultaneously
B) Processing one request at a time
C) Reducing cost
D) Improving quality

**9. What is the difference between concurrent and parallel execution?**

A) Concurrent is interleaved; parallel is simultaneous
B) Parallel is interleaved; concurrent is simultaneous
C) They are the same
D) Concurrent is faster

**10. Why is async programming important for AI applications?**

A) AI applications are I/O-bound and latency-sensitive
B) AI applications are CPU-bound
C) AI applications are memory-bound
D) AI applications are storage-bound

---

### Module 19 Quiz: Resilient AI Systems

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is a retry system?**

A) A system that retries failed operations
B) A system that ignores failures
C) A system that logs failures
D) A system that crashes on failure

**2. What is exponential backoff?**

A) Increasing delay between retries exponentially
B) Increasing delay linearly
C) No delay between retries
D) Random delay between retries

**3. What is a circuit breaker?**

A) A pattern that stops requests after failures
B) A pattern that retries requests
C) A pattern that logs requests
D) A pattern that ignores requests

**4. What are the three states of a circuit breaker?**

A) Closed, Open, Half-Open
B) On, Off, Standby
C) Active, Inactive, Pending
D) Running, Stopped, Paused

**5. What is the purpose of a timeout?**

A) To prevent hanging operations
B) To speed up operations
C) To reduce cost
D) To improve quality

**6. What is rate limiting?**

A) Limiting the number of requests
B) Increasing the number of requests
C) Ignoring requests
D) Logging requests

**7. What is a bulkhead pattern?**

A) Isolating resources to prevent cascading failures
B) Sharing resources
C) Ignoring resources
D) Logging resources

**8. What is graceful degradation?**

A) Maintaining partial functionality when some components fail
B) Complete failure
C) No failure handling
D) Instant recovery

**9. What is the purpose of jitter in retries?**

A) To prevent synchronized retries (thundering herd)
B) To speed up retries
C) To reduce cost
D) To improve quality

**10. What is the difference between a retry and a fallback?**

A) Retry tries the same operation; fallback uses an alternative
B) Retry uses an alternative; fallback retries the same operation
C) They are the same
D) Retry is faster

---

### Module 20 Quiz: AI Observability

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What are the three pillars of observability?**

A) Logging, Tracing, Metrics
B) Logging, Monitoring, Alerting
C) Tracing, Debugging, Profiling
D) Metrics, Monitoring, Alerting

**2. What is structured logging?**

A) Logging in a structured format like JSON
B) Logging in plain text
C) Logging only errors
D) Logging only warnings

**3. What is tracing?**

A) Tracking request flows through a system
B) Tracking errors
C) Tracking logs
D) Tracking metrics

**4. What is token usage monitoring?**

A) Tracking the number of tokens used
B) Tracking the number of requests
C) Tracking the cost
D) Tracking the latency

**5. What is latency analysis?**

A) Measuring response time
B) Measuring cost
C) Measuring accuracy
D) Measuring quality

**6. What is the purpose of prompt versioning?**

A) To track changes in prompts
B) To track changes in models
C) To track changes in data
D) To track changes in cost

**7. What is a metric in observability?**

A) A quantitative measurement
B) A qualitative assessment
C) A log entry
D) A trace span

**8. What is the purpose of dashboards?**

A) To visualize metrics and logs
B) To generate logs
C) To trace requests
D) To monitor cost

**9. What is the difference between logging and tracing?**

A) Logging is for events; tracing is for request flows
B) Tracing is for events; logging is for request flows
C) They are the same
D) Logging is for errors; tracing is for logs

**10. Why is cost monitoring important for AI applications?**

A) AI API calls have variable costs based on token usage
B) AI API calls have fixed costs
C) AI API calls are free
D) Cost doesn't matter

---

### Module 21 Quiz: AI Security

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is prompt injection?**

A) Inserting malicious instructions into a prompt
B) Injecting data into a database
C) Injecting code into a program
D) Injecting tokens into a response

**2. What is a jailbreak attempt?**

A) Bypassing safety measures
B) Breaking into a system
C) Logging into an account
D) Accessing a database

**3. What is data leakage?**

A) Exposing sensitive information
B) Leaking data from a database
C) Logging data
D) Processing data

**4. What is tool abuse?**

A) Misusing available tools
B) Using tools correctly
C) Logging tool usage
D) Documenting tool usage

**5. What is the principle of least privilege?**

A) Giving only necessary permissions
B) Giving all permissions
C) Giving no permissions
D) Giving random permissions

**6. What is the purpose of input sanitization?**

A) To remove malicious content
B) To add content
C) To log content
D) To process content

**7. What is output filtering?**

A) Checking for sensitive data in outputs
B) Filtering inputs
C) Filtering logs
D) Filtering metrics

**8. What is the purpose of content moderation?**

A) To ensure safe and appropriate content
B) To generate content
C) To log content
D) To process content

**9. What is a guardrail?**

A) A safety constraint or control
B) A type of model
C) A type of tool
D) A type of prompt

**10. What are responsible AI principles?**

A) Guidelines for ethical AI development
B) Technical specifications
C) Performance metrics
D) Cost optimization strategies

---

### Phase 6 Test: AI Application Engineering

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. What is asynchronous programming?**

A) A programming model that allows non-blocking operations
B) A programming model that blocks operations
C) A programming model that uses only one thread
D) A programming model that ignores I/O

**2. What is Server-Sent Events (SSE)?**

A) A technology for sending real-time updates from server to client
B) A technology for sending updates from client to server
C) A technology for batch processing
D) A technology for compression

**3. What is the purpose of WebSockets?**

A) Bidirectional, real-time communication
B) One-way communication
C) Batch processing
D) Compression

**4. What is a circuit breaker?**

A) A pattern that stops requests after failures
B) A pattern that retries requests
C) A pattern that logs requests
D) A pattern that ignores requests

**5. What is exponential backoff?**

A) Increasing delay between retries exponentially
B) Increasing delay linearly
C) No delay between retries
D) Random delay between retries

**6. What are the three pillars of observability?**

A) Logging, Tracing, Metrics
B) Logging, Monitoring, Alerting
C) Tracing, Debugging, Profiling
D) Metrics, Monitoring, Alerting

**7. What is structured logging?**

A) Logging in a structured format like JSON
B) Logging in plain text
C) Logging only errors
D) Logging only warnings

**8. What is prompt injection?**

A) Inserting malicious instructions into a prompt
B) Injecting data into a database
C) Injecting code into a program
D) Injecting tokens into a response

**9. What is a jailbreak attempt?**

A) Bypassing safety measures
B) Breaking into a system
C) Logging into an account
D) Accessing a database

**10. What is the principle of least privilege?**

A) Giving only necessary permissions
B) Giving all permissions
C) Giving no permissions
D) Giving random permissions

**11. What is latency analysis?**

A) Measuring response time
B) Measuring cost
C) Measuring accuracy
D) Measuring quality

**12. What is the purpose of prompt versioning?**

A) To track changes in prompts
B) To track changes in models
C) To track changes in data
D) To track changes in cost

**13. What is a bulkhead pattern?**

A) Isolating resources to prevent cascading failures
B) Sharing resources
C) Ignoring resources
D) Logging resources

**14. What is the purpose of input sanitization?**

A) To remove malicious content
B) To add content
C) To log content
D) To process content

**15. What is a guardrail?**

A) A safety constraint or control
B) A type of model
C) A type of tool
D) A type of prompt

---

**Section B: Short Answer (5 questions)**

**16. Explain the difference between synchronous and asynchronous programming.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between a retry and a fallback?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. What are the three pillars of observability and what does each do?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. What is prompt injection and how can you prevent it?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. Explain how circuit breakers work.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Write code for an asynchronous AI client.**

```python
# Your code here
```

**22. Implement a retry system with exponential backoff.**

```python
# Your code here
```

**23. Write a structured logger for AI applications.**

```python
# Your code here
```

**24. Design a security guardrail system for AI.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**25. Implement a prompt injection detector.**

```python
# Your code here
```

---

## Phase 7: Production AI Architecture

### Module 22 Quiz: AI System Architecture

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is an AI gateway?**

A) A unified entry point for AI services
B) A model
C) A vector database
D) A prompt template

**2. What is the purpose of model routing?**

A) To select the best model for each request
B) To train models
C) To evaluate models
D) To deploy models

**3. What is semantic caching?**

A) Caching responses based on meaning
B) Caching responses based on exact matches
C) Caching responses based on time
D) Caching responses based on cost

**4. What is load balancing?**

A) Distributing requests across models
B) Balancing weights
C) Balancing costs
D) Balancing quality

**5. What is model fallback?**

A) Using an alternative model when the primary fails
B) Training a model
C) Evaluating a model
D) Deploying a model

**6. What is a multi-model strategy?**

A) Using multiple models to optimize cost and quality
B) Using one model
C) Using no model
D) Using only the most expensive model

**7. What is the purpose of rate limiting?**

A) To prevent overwhelming the system
B) To speed up processing
C) To reduce cost
D) To improve quality

**8. What is a cache TTL?**

A) Time to Live (expiration time)
B) Time to Load
C) Time to Log
D) Time to Launch

**9. What is the difference between exact match and semantic caching?**

A) Exact match caches identical queries; semantic caches similar queries
B) Semantic caches identical queries; exact caches similar queries
C) They are the same
D) Exact match is faster

**10. What is the purpose of a circuit breaker in architecture?**

A) To prevent cascading failures
B) To speed up processing
C) To reduce cost
D) To improve quality

---

### Module 23 Quiz: Deployment

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is containerization?**

A) Packaging an application with its dependencies
B) Creating a container
C) Running an application
D) Deploying an application

**2. What is Docker?**

A) A containerization platform
B) A programming language
C) A database
D) A cloud service

**3. What is Kubernetes?**

A) A container orchestration platform
B) A programming language
C) A database
D) A cloud service

**4. What is the purpose of CI/CD?**

A) To automate build, test, and deployment
B) To create containers
C) To train models
D) To evaluate models

**5. What is a canary deployment?**

A) Gradually rolling out changes to a small subset
B) Deploying all changes at once
C) Deploying no changes
D) Deploying changes randomly

**6. What is a blue-green deployment?**

A) Two identical environments for zero downtime
B) One environment
C) No environment
D) A random environment

**7. What is the purpose of health checks?**

A) To monitor service health
B) To speed up deployment
C) To reduce cost
D) To improve quality

**8. What is the purpose of a liveness probe?**

A) To check if the container is running
B) To check if the container is ready for traffic
C) To check if the container is healthy
D) To check if the container is logging

**9. What is the purpose of a readiness probe?**

A) To check if the container is ready for traffic
B) To check if the container is running
C) To check if the container is healthy
D) To check if the container is logging

**10. What is the purpose of a rollback?**

A) To revert to a previous version
B) To deploy a new version
C) To test a version
D) To evaluate a version

---

### Module 24 Quiz: AI Evaluation & Continuous Improvement

**Time Limit: 15 minutes**
**Total Questions: 10**

---

**1. What is benchmarking?**

A) Measuring AI system performance
B) Training AI systems
C) Deploying AI systems
D) Evaluating AI systems

**2. What is A/B testing?**

A) Comparing two versions
B) Testing one version
C) Testing no version
D) Testing random versions

**3. What is LLM-as-a-Judge?**

A) Using an LLM to evaluate quality
B) Using a human to evaluate quality
C) Using a rule-based system to evaluate quality
D) Using no evaluation

**4. What is a feedback loop?**

A) Using feedback to continuously improve
B) Giving feedback once
C) Ignoring feedback
D) Generating feedback

**5. What is regression testing?**

A) Testing to prevent regressions
B) Testing new features
C) Testing performance
D) Testing security

**6. What is the purpose of continuous improvement?**

A) To iteratively improve the system
B) To deploy the system once
C) To train the system once
D) To evaluate the system once

**7. What is the purpose of automated evaluation?**

A) To evaluate at scale
B) To evaluate manually
C) To ignore evaluation
D) To evaluate once

**8. What is the difference between A/B testing and benchmarking?**

A) A/B compares versions; benchmarking measures absolute performance
B) Benchmarking compares versions; A/B measures absolute performance
C) They are the same
D) A/B is faster

**9. What is the purpose of monitoring in continuous improvement?**

A) To track performance and detect issues
B) To ignore performance
C) To generate performance
D) To evaluate performance

**10. What is the first step in the continuous improvement process?**

A) Collect data
B) Deploy changes
C) Test changes
D) Monitor performance

---

### Phase 7 Test: Production AI Architecture

**Time Limit: 45 minutes**
**Total Questions: 25**

---

**Section A: Multiple Choice (15 questions)**

**1. What is an AI gateway?**

A) A unified entry point for AI services
B) A model
C) A vector database
D) A prompt template

**2. What is the purpose of model routing?**

A) To select the best model for each request
B) To train models
C) To evaluate models
D) To deploy models

**3. What is semantic caching?**

A) Caching responses based on meaning
B) Caching responses based on exact matches
C) Caching responses based on time
D) Caching responses based on cost

**4. What is load balancing?**

A) Distributing requests across models
B) Balancing weights
C) Balancing costs
D) Balancing quality

**5. What is model fallback?**

A) Using an alternative model when the primary fails
B) Training a model
C) Evaluating a model
D) Deploying a model

**6. What is containerization?**

A) Packaging an application with its dependencies
B) Creating a container
C) Running an application
D) Deploying an application

**7. What is Docker?**

A) A containerization platform
B) A programming language
C) A database
D) A cloud service

**8. What is Kubernetes?**

A) A container orchestration platform
B) A programming language
C) A database
D) A cloud service

**9. What is the purpose of CI/CD?**

A) To automate build, test, and deployment
B) To create containers
C) To train models
D) To evaluate models

**10. What is a canary deployment?**

A) Gradually rolling out changes to a small subset
B) Deploying all changes at once
C) Deploying no changes
D) Deploying changes randomly

**11. What is benchmarking?**

A) Measuring AI system performance
B) Training AI systems
C) Deploying AI systems
D) Evaluating AI systems

**12. What is A/B testing?**

A) Comparing two versions
B) Testing one version
C) Testing no version
D) Testing random versions

**13. What is LLM-as-a-Judge?**

A) Using an LLM to evaluate quality
B) Using a human to evaluate quality
C) Using a rule-based system to evaluate quality
D) Using no evaluation

**14. What is a feedback loop?**

A) Using feedback to continuously improve
B) Giving feedback once
C) Ignoring feedback
D) Generating feedback

**15. What is regression testing?**

A) Testing to prevent regressions
B) Testing new features
C) Testing performance
D) Testing security

---

**Section B: Short Answer (5 questions)**

**16. Explain the purpose of an AI gateway.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**17. What is the difference between blue-green and canary deployment?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**18. What is the purpose of A/B testing in AI systems?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**19. Explain the continuous improvement process for AI systems.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**20. What is the difference between a liveness probe and a readiness probe?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (5 questions)**

**21. Design an AI gateway with authentication, rate limiting, and routing.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**22. Write a Dockerfile for an AI service.**

```dockerfile
# Your code here
```

**23. Write a Kubernetes deployment manifest.**

```yaml
# Your code here
```

**24. Design an A/B testing system for AI prompts.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**25. Explain how to implement a feedback loop for continuous improvement.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

## Capstone Project Assessments

### Capstone Project 1: AI Chatbot with Memory

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Functionality** | Fully functional chatbot with working memory | Basic functionality with some issues | Incomplete or non-functional | /5 |
| **Memory System** | Both short-term and long-term memory implemented | One type of memory implemented | No memory implemented | /5 |
| **User Experience** | Smooth conversation flow, intuitive | Usable but with friction | Difficult to use | /5 |
| **Code Quality** | Clean, well-commented, maintainable | Decent code with some issues | Messy or unorganized | /5 |
| **Documentation** | Comprehensive documentation | Basic documentation | Minimal or no documentation | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Does the chatbot remember previous conversations across sessions?
2. Can it recall specific user details?
3. Is the memory system efficient and well-structured?
4. Is the code well-organized and documented?

---

### Capstone Project 2: Private Knowledge Assistant (RAG)

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Document Ingestion** | Handles multiple document types | Handles one document type | No ingestion | /5 |
| **Retrieval** | Accurate, relevant retrieval | Somewhat accurate | Poor retrieval | /5 |
| **Generation** | Accurate, cited responses | Responses without citations | Poor quality responses | /5 |
| **Performance** | Fast and efficient | Acceptable performance | Slow or inefficient | /5 |
| **Code Quality** | Clean, well-documented | Decent code | Poor code quality | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Can the system answer questions based on provided documents?
2. Are responses accurate and well-cited?
3. Does the system handle different document types?
4. Is the retrieval efficient and accurate?

---

### Capstone Project 3: AI Coding Assistant

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Code Generation** | Generates correct, idiomatic code | Generates working code | Generates incorrect code | /5 |
| **Code Explanation** | Clear, thorough explanations | Adequate explanations | Poor explanations | /5 |
| **Debugging** | Identifies and fixes bugs | Identifies issues | Cannot debug | /5 |
| **Repository Awareness** | Understands repository context | Basic understanding | No context awareness | /5 |
| **Code Quality** | Clean, well-documented | Decent code | Poor code quality | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Can the assistant generate working code for common tasks?
2. Does it explain code clearly and accurately?
3. Can it identify and fix bugs?
4. Does it understand repository structure?

---

### Capstone Project 4: Autonomous Research Agent

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Research Quality** | Thorough, comprehensive research | Basic research | Incomplete research | /5 |
| **Synthesis** | Excellent synthesis of findings | Good synthesis | Poor synthesis | /5 |
| **Report Quality** | Well-structured, clear report | Adequate report | Poorly structured report | /5 |
| **Citations** | Accurate, well-formatted citations | Some citations | No citations | /5 |
| **Autonomy** | Fully autonomous | Partially autonomous | Requires human intervention | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Does the agent produce comprehensive research?
2. Is the report well-structured and clear?
3. Are citations accurate and properly formatted?
4. How autonomous is the agent?

---

### Capstone Project 5: Document Intelligence Platform

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **OCR Quality** | High accuracy text extraction | Moderate accuracy | Poor accuracy | /5 |
| **Structured Extraction** | Accurate structured data | Somewhat accurate | Poor extraction | /5 |
| **Classification** | Accurate classification | Somewhat accurate | Poor classification | /5 |
| **Summarization** | High-quality summaries | Adequate summaries | Poor summaries | /5 |
| **Code Quality** | Clean, well-documented | Decent code | Poor code quality | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Does the platform accurately extract text from documents?
2. Can it extract structured data from invoices and forms?
3. Does it classify documents correctly?
4. Are summaries accurate and useful?

---

### Capstone Project 6: Customer Support Copilot

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Integration** | Seamless integration with ticketing system | Basic integration | No integration | /5 |
| **Knowledge Base** | Effective knowledge retrieval | Somewhat effective | Poor retrieval | /5 |
| **Response Quality** | High-quality, accurate responses | Adequate responses | Poor responses | /5 |
| **Escalation** | Accurate escalation detection | Somewhat accurate | No escalation | /5 |
| **Code Quality** | Clean, well-documented | Decent code | Poor code quality | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Does the copilot integrate with the ticketing system?
2. Does it retrieve relevant knowledge base content?
3. Are responses accurate and helpful?
4. Does it detect when escalation is needed?

---

### Capstone Project 7: AI Workflow Automation Engine

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Tool Integration** | Multiple tools integrated | Some tools integrated | Few or no tools | /5 |
| **Orchestration** | Complex workflows automated | Simple workflows automated | No workflows | /5 |
| **Error Handling** | Robust error handling | Basic error handling | Poor error handling | /5 |
| **User Experience** | Intuitive, easy to use | Usable | Difficult to use | /5 |
| **Code Quality** | Clean, well-documented | Decent code | Poor code quality | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Does the engine integrate with email, database, and calendar?
2. Can it automate complex workflows?
3. Does it handle errors gracefully?
4. Is it easy to use and configure?

---

### Capstone Project 8: Enterprise AI Platform

**Assessment Rubric**

| Criteria | Excellent (5) | Good (3) | Needs Improvement (1) | Score |
|----------|---------------|----------|----------------------|-------|
| **Architecture** | Well-designed, scalable architecture | Decent architecture | Poor architecture | /5 |
| **Features** | All features implemented | Most features implemented | Few features implemented | /5 |
| **Security** | Robust security measures | Basic security | Poor security | /5 |
| **Observability** | Comprehensive observability | Basic observability | No observability | /5 |
| **Deployment** | Production-ready deployment | Deployable but with issues | Not deployable | /5 |
| **Total** | | | | /25 |

**Evaluation Questions:**

1. Is the architecture well-designed and scalable?
2. Does it include RAG, MCP, and agent orchestration?
3. Are security measures robust?
4. Is the system observable and deployable?

---

## Final Comprehensive Exam

**Time Limit: 90 minutes**
**Total Questions: 50**

---

**Section A: Multiple Choice (30 questions)**

**1. What is the key innovation introduced in the "Attention Is All You Need" paper?**

A) Recurrent neural networks
B) The Transformer architecture
C) Convolutional neural networks
D) Support vector machines

**2. What is an embedding?**

A) A word in a dictionary
B) A vector representing meaning
C) A sentence in a document
D) A token in a text

**3. What does temperature = 0.0 produce?**

A) Completely random output
B) Deterministic (greedy) output
C) Creative output
D) Nonsensical output

**4. What is the context window of GPT-4o-mini?**

A) 8,192 tokens
B) 16,384 tokens
C) 128,000 tokens
D) 2,000,000 tokens

**5. What is the purpose of rate limiting?**

A) To increase speed
B) To prevent overwhelming the API
C) To reduce costs
D) To improve quality

**6. What is a system prompt?**

A) The user's question
B) Instructions defining the AI's persona and behavior
C) The AI's response
D) The API endpoint

**7. What is Chain-of-Thought prompting?**

A) Asking the AI to show its reasoning step by step
B) Asking the AI to be creative
C) Asking the AI to be concise
D) Asking the AI to generate code

**8. What is the most common format for structured outputs?**

A) XML
B) JSON
C) HTML
D) CSV

**9. What is function calling?**

A) A feature that allows LLMs to call external functions
B) A way to call functions within the LLM
C) A way to call APIs
D) A way to call databases

**10. What is a tool schema?**

A) A description of the tool's implementation
B) A JSON description of the tool's parameters and purpose
C) A Python class
D) A database schema

**11. What is sequential execution?**

A) Tools run simultaneously
B) Tools run one after another
C) Tools run randomly
D) Tools run in any order

**12. What is MCP?**

A) A protocol for AI-tool integration
B) A programming language
C) A database
D) A cloud service

**13. What are the stages of a RAG pipeline?**

A) Ingestion, Retrieval, Generation
B) Training, Validation, Testing
C) Collection, Processing, Analysis
D) Input, Processing, Output

**14. What is hybrid search?**

A) Combining keyword and semantic search
B) Combining two semantic searches
C) Combining two keyword searches
D) Combining search with generation

**15. What is parent-child retrieval?**

A) Retrieving small chunks (children) but returning large chunks (parents)
B) Retrieving only large chunks
C) Retrieving only small chunks
D) Retrieving random chunks

**16. What makes an AI agent different from a simple chatbot?**

A) Agents can plan, reason, and take autonomous action
B) Agents are faster
C) Agents are cheaper
D) Agents use smaller models

**17. What are the key components of an AI agent?**

A) Planning, Reasoning, Memory, Tool Use, Reflection
B) Input, Output, Processing
C) Training, Validation, Testing
D) Collection, Processing, Analysis

**18. What is a multi-agent system?**

A) A system with multiple AI agents
B) A system with one AI agent
C) A system with no AI agents
D) A system with only humans

**19. What are the four types of memory in AI agents?**

A) Short-term, Long-term, Episodic, Semantic
B) Short-term, Long-term, Working, Permanent
C) Immediate, Recent, Past, Permanent
D) Current, History, Future, Permanent

**20. What is asynchronous programming?**

A) A programming model that allows non-blocking operations
B) A programming model that blocks operations
C) A programming model that uses only one thread
D) A programming model that ignores I/O

**21. What is a circuit breaker?**

A) A pattern that stops requests after failures
B) A pattern that retries requests
C) A pattern that logs requests
D) A pattern that ignores requests

**22. What are the three pillars of observability?**

A) Logging, Tracing, Metrics
B) Logging, Monitoring, Alerting
C) Tracing, Debugging, Profiling
D) Metrics, Monitoring, Alerting

**23. What is prompt injection?**

A) Inserting malicious instructions into a prompt
B) Injecting data into a database
C) Injecting code into a program
D) Injecting tokens into a response

**24. What is an AI gateway?**

A) A unified entry point for AI services
B) A model
C) A vector database
D) A prompt template

**25. What is the purpose of model routing?**

A) To select the best model for each request
B) To train models
C) To evaluate models
D) To deploy models

**26. What is Docker?**

A) A containerization platform
B) A programming language
C) A database
D) A cloud service

**27. What is Kubernetes?**

A) A container orchestration platform
B) A programming language
C) A database
D) A cloud service

**28. What is A/B testing?**

A) Comparing two versions
B) Testing one version
C) Testing no version
D) Testing random versions

**29. What is LLM-as-a-Judge?**

A) Using an LLM to evaluate quality
B) Using a human to evaluate quality
C) Using a rule-based system to evaluate quality
D) Using no evaluation

**30. What is a feedback loop?**

A) Using feedback to continuously improve
B) Giving feedback once
C) Ignoring feedback
D) Generating feedback

---

**Section B: Short Answer (10 questions)**

**31. Explain what a context window is and why it's important.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**32. What is the difference between tokens and words?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**33. Explain the RAG pipeline in 3-5 sentences.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**34. What is the difference between sequential and parallel execution?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**35. Describe the agent cycle in 3-5 sentences.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**36. What is the difference between short-term and long-term memory?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**37. Explain the difference between synchronous and asynchronous programming.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**38. What is the difference between a retry and a fallback?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**39. What are the three pillars of observability and what does each do?**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

**40. Explain the purpose of an AI gateway.**

```
________________________________________________________________________
________________________________________________________________________
________________________________________________________________________
```

---

**Section C: Code/Scenario Questions (10 questions)**

**41. Write code to generate an embedding for a text.**

```python
# Your code here
```

**42. Write code to count tokens in a text.**

```python
# Your code here
```

**43. Write a prompt that uses Chain-of-Thought to solve a math problem.**

```python
# Your code here
```

**44. Write code to generate a JSON response with schema validation.**

```python
# Your code here
```

**45. Define a tool schema for a calculator function.**

```json
# Your code here
```

**46. Write code to implement a simple RAG pipeline.**

```python
# Your code here
```

**47. Write a simple agent class with planning and execution.**

```python
# Your code here
```

**48. Write a Dockerfile for an AI service.**

```dockerfile
# Your code here
```

**49. Write a Kubernetes deployment manifest.**

```yaml
# Your code here
```

**50. Implement a retry system with exponential backoff.**

```python
# Your code here
```

---

## Answer Keys

### Module 1 Quiz Answer Key

1. B
2. C
3. B
4. B
5. B
6. B
7. A
8. A
9. D
10. B

### Module 2 Quiz Answer Key

1. B
2. B
3. B
4. C
5. B
6. D
7. A
8. A
9. A
10. B

### Module 3 Quiz Answer Key

1. D
2. B
3. A
4. B
5. B
6. B
7. B
8. A
9. A
10. A

### Module 4 Quiz Answer Key

1. A
2. B
3. D
4. C
5. A
6. B
7. C
8. A
9. B
10. B

### Phase 1 Test Answer Key

**Section A:**
1. C
2. B
3. B
4. C
5. B
6. B
7. A
8. B
9. B
10. B
11. B
12. D
13. B
14. B
15. C

**Section B:**
16. A context window is the maximum number of tokens an LLM can process in a single request. It's important because exceeding it results in errors or lost context.
17. Tokens are the smallest units an LLM processes; they can be words, parts of words, punctuation, or spaces. Words are complete lexical units.
18. Temperature controls randomness, Top-K limits candidate tokens, and Top-P filters tokens based on cumulative probability. They work together to control the probability distribution from which the next token is sampled.
19. Embeddings are vector representations of meaning. They enable semantic search, similarity measurement, and are the foundation of RAG.
20. Truncation (drop oldest), sliding window (keep recent), summarization (condense old messages).

**Section C:**
21. See code in Module 2 notes.
22. See code in Module 2 notes.
23. See code in Module 4 notes.
24. The request would be rejected as it exceeds the 128,000 token context window.
25. Temperature=0.0 (deterministic), Top-P=1.0 (no filtering), low max tokens.

---

### Module 5 Quiz Answer Key

1. B
2. B
3. B
4. A
5. B
6. C
7. A
8. A
9. B
10. B

### Module 6 Quiz Answer Key

1. B
2. A
3. B
4. B
5. A
6. A
7. B
8. A
9. B
10. B

### Module 7 Quiz Answer Key

1. B
2. B
3. A
4. B
5. B
6. B
7. D
8. B
9. B
10. B

### Module 8 Quiz Answer Key

1. B
2. D
3. A
4. A
5. B
6. D
7. C
8. B
9. C
10. D

### Phase 2 Test Answer Key

**Section A:**
1. B
2. B
3. A
4. B
5. B
6. B
7. A
8. B
9. B
10. A
11. A
12. A
13. B
14. A
15. D

**Section B:**
16. Zero-shot has no examples; few-shot provides examples in the prompt.
17. System prompt defines the AI's persona; user prompt is the actual question.
18. Use JSON mode, define a schema, validate the output.
19. Real-time display, better user experience, faster perceived response.
20. Text, images, audio, video.

**Section C:**
21. See Module 6 notes.
22. See Module 7 notes.
23. "You are a senior software engineer with 15 years of experience. You provide precise, technical, and accurate information."
24. See Module 8 notes.
25. See Module 7 notes.

---

### Module 9 Quiz Answer Key

1. A
2. B
3. C
4. B
5. A
6. A
7. A
8. D
9. A
10. B

### Module 10 Quiz Answer Key

1. A
2. B
3. A
4. B
5. A
6. A
7. B
8. B
9. A
10. B

### Module 11 Quiz Answer Key

1. A
2. A
3. D
4. A
5. B
6. C
7. D
8. D
9. A
10. D

### Phase 3 Test Answer Key

**Section A:**
1. A
2. B
3. B
4. B
5. A
6. A
7. A
8. A
9. D
10. A
11. B
12. D
13. B
14. A
15. D

**Section B:**
16. User query → LLM decides to call function → generates function call → executes function → returns result → LLM generates natural language response.
17. Sequential runs tools one after another; parallel runs them simultaneously.
18. Resources (data), Prompts (templates), Tools (executable functions).
19. Use retries, fallbacks, and graceful degradation.
20. Standardization, interoperability, discoverability, security.

**Section C:**
21. See Module 9 notes.
22. See Module 10 notes.
23. See Module 11 notes.
24. Use retry with exponential backoff, fallback to alternative tool, or degrade functionality.
25. A tool registry stores tools with their schemas and handlers, allowing discovery and execution.

---

### Module 12 Quiz Answer Key

1. A
2. C
3. A
4. D
5. A
6. B
7. B
8. B
9. B
10. A

### Module 13 Quiz Answer Key

1. A
2. A
3. B
4. C
5. A
6. A
7. A
8. A
9. B
10. A

### Module 14 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Phase 4 Test Answer Key

**Section A:**
1. A
2. C
3. D
4. A
5. A
6. A
7. A
8. A
9. A
10. A
11. B
12. A
13. A
14. B
15. A

**Section B:**
16. Document ingestion → chunking → embedding → storing → retrieval → context construction → generation → citation.
17. Hybrid combines keyword and semantic; pure semantic uses only embeddings.
18. Retrieves small chunks (children) for precision, returns large chunks (parents) for context.
19. Chunk quality, embedding quality, retrieval quality, context window, prompt design, model choice.
20. Tune Top-K, use hybrid search, optimize chunk size, re-rank results, use better embeddings.

**Section C:**
21. See Module 12 notes.
22. See Module 13 notes.
23. Hybrid search combines BM25 (keyword) and cosine similarity (semantic) with weighted scores.
24. See Module 12 notes.
25. Track source metadata and include source references in the generated response.

---

### Module 15 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. D
10. A

### Module 16 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Module 17 Quiz Answer Key

1. A
2. A
3. B
4. C
5. D
6. A
7. A
8. A
9. A
10. A

### Phase 5 Test Answer Key

**Section A:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. B
11. A
12. A
13. A
14. A
15. A

**Section B:**
16. Agent cycle: plan → execute → reflect → learn → repeat.
17. Short-term is immediate context; long-term is persistent knowledge.
18. Hierarchical has a coordinator; swarm is decentralized.
19. To evaluate performance, learn from mistakes, and improve future actions.
20. Moving important memories from short-term to long-term storage.

**Section C:**
21. See Module 15 notes.
22. See Module 16 notes.
23. See Module 17 notes.
24. Multi-agent system: coordinator assigns tasks to researcher, analyzer, writer, and reviewer agents.
25. Reflection evaluates the agent's performance, identifies areas for improvement, and updates behavior.

---

### Module 18 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Module 19 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Module 20 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Module 21 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Phase 6 Test Answer Key

**Section A:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A
11. A
12. A
13. A
14. A
15. A

**Section B:**
16. Synchronous blocks operations; asynchronous allows non-blocking operations.
17. Retry tries the same operation; fallback uses an alternative.
18. Logging (events), Tracing (request flows), Metrics (measurements).
19. Prompt injection inserts malicious instructions; prevent with input validation and sanitization.
20. Circuit breaker stops requests after failures (Closed → Open → Half-Open → Closed).

**Section C:**
21. See Module 18 notes.
22. See Module 19 notes.
23. See Module 20 notes.
24. Security guardrails: input validation, output filtering, access control, rate limiting, monitoring.
25. See Module 21 notes.

---

### Module 22 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Module 23 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Module 24 Quiz Answer Key

1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A

### Phase 7 Test Answer Key

**Section A:**
1. A
2. A
3. A
4. A
5. A
6. A
7. A
8. A
9. A
10. A
11. A
12. A
13. A
14. A
15. A

**Section B:**
16. An AI gateway provides a unified entry point with authentication, rate limiting, and routing.
17. Blue-green uses two identical environments; canary gradually rolls out changes.
18. A/B testing compares two versions to determine which performs better.
19. Continuous improvement: collect data → measure → identify issues → prioritize → implement → test → deploy → monitor → repeat.
20. Liveness checks if the container is running; readiness checks if it's ready for traffic.

**Section C:**
21. Gateway design includes authentication (API keys), rate limiting (token bucket), and routing (model selection).
22. See Module 23 notes.
23. See Module 23 notes.
24. A/B testing: assign users to variants, collect metrics, analyze results, determine winner.
25. Feedback loop: collect user feedback → analyze → identify improvements → implement → deploy → monitor.

---

### Final Exam Answer Key

**Section A:**
1. B
2. B
3. B
4. C
5. B
6. B
7. A
8. B
9. A
10. B
11. B
12. A
13. A
14. A
15. A
16. A
17. A
18. A
19. A
20. A
21. A
22. A
23. A
24. A
25. A
26. A
27. A
28. A
29. A
30. A

**Section B:**
31. A context window is the maximum number of tokens an LLM can process in a single request. It's important because exceeding it results in errors or lost context.
32. Tokens are the smallest units an LLM processes; they can be words, parts of words, punctuation, or spaces. Words are complete lexical units.
33. RAG pipeline: document ingestion → chunking → embedding → storing → retrieval → context construction → generation → citation.
34. Sequential runs tools one after another; parallel runs them simultaneously.
35. Agent cycle: plan → execute → reflect → learn → repeat.
36. Short-term is immediate context; long-term is persistent knowledge.
37. Synchronous blocks operations; asynchronous allows non-blocking operations.
38. Retry tries the same operation; fallback uses an alternative.
39. Logging (events), Tracing (request flows), Metrics (measurements).
40. An AI gateway provides a unified entry point with authentication, rate limiting, and routing.

**Section C:**
41-50: See individual module notes for code and implementation examples.

---

## Grade Tracking Sheet

| Assessment | Score | Percentage | Grade |
|------------|-------|------------|-------|
| Module 1 Quiz | /10 | % | |
| Module 2 Quiz | /10 | % | |
| Module 3 Quiz | /10 | % | |
| Module 4 Quiz | /10 | % | |
| Phase 1 Test | /25 | % | |
| Module 5 Quiz | /10 | % | |
| Module 6 Quiz | /10 | % | |
| Module 7 Quiz | /10 | % | |
| Module 8 Quiz | /10 | % | |
| Phase 2 Test | /25 | % | |
| Module 9 Quiz | /10 | % | |
| Module 10 Quiz | /10 | % | |
| Module 11 Quiz | /10 | % | |
| Phase 3 Test | /25 | % | |
| Module 12 Quiz | /10 | % | |
| Module 13 Quiz | /10 | % | |
| Module 14 Quiz | /10 | % | |
| Phase 4 Test | /25 | % | |
| Module 15 Quiz | /10 | % | |
| Module 16 Quiz | /10 | % | |
| Module 17 Quiz | /10 | % | |
| Phase 5 Test | /25 | % | |
| Module 18 Quiz | /10 | % | |
| Module 19 Quiz | /10 | % | |
| Module 20 Quiz | /10 | % | |
| Module 21 Quiz | /10 | % | |
| Phase 6 Test | /25 | % | |
| Module 22 Quiz | /10 | % | |
| Module 23 Quiz | /10 | % | |
| Module 24 Quiz | /10 | % | |
| Phase 7 Test | /25 | % | |
| Final Exam | /50 | % | |

---

**End of Quiz and Test Bank**
